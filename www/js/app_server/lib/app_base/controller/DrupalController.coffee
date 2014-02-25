define (require, exports, module) ->

    DrupalModel = require 'app_base/model/DrupalModel'
    ServiceDrupal = require 'services/ServiceDrupal'
    unserialize_php = require "util/unserialize_php"
    self = {}

    module.exports = class DrupalController

        constructor: (options = {app: null,callback: null}) ->
          self = @
          @application = options.app
          @application.drupal = @
          @application.model = new DrupalModel()
          @model = @application.model
          @appSettings = @application.appSettings
          @callbackFn = options.callback
          @unserialize_php = unserialize_php
          @serviceClass = new ServiceDrupal
            gateway: "http://"+@appSettings.domain+"/?q=services/jsonp"
            domain: @appSettings.domain
            requireSession: @appSettings.use_sessions
          if @appSettings.online == false
            @callbackFn.call(@application,@application)
          else
            @connect()

        service: (service_method, args, success) ->
          @serviceClass.service service_method, args, success

        connect: ->
          if @appSettings.use_sessions != true
            @getParams(@onConnected)
          else
            @serviceClass.connect (data) =>
              @model.user = data.user
              @model.sessid = data.sessid
              @getParams(@onConnected)

        onConnected: (data) =>
          @callbackFn.call(@application,@application)

        getParams: (callback) =>
          model = @model
          @serviceClass.service "site.getParams", {}, (data) ->
            model.siteParams = data
            callback.call @application, data

        getNode: (nid, callback) =>
          model = @model
          @serviceClass.service "node.get", {nid:nid}, (data) ->
            model.nodes[data.nid] = data
            callback.call @application, data

        getNodes: (nids, callback) =>
          model = @model
          @serviceClass.service "site.getNodes", {nids:nids}, (data) ->
            for p in data
              if p != undefined
                model.nodes[p.nid] = p
            callback.call @application, data

        getMenu: (mid, callback) =>
          @serviceClass.service "menu.get", {menu_id:mid,fields:undefined}, (data) =>
            @application.model.menus[mid] = new Object(data)
            callback.call @application, data, mid

        getMenus: (mids, callback, preload_nodes = true) =>
          i = 0
          for p of mids
            @getMenu mids[p], (data, mid) ->
              callback.call @application, mids  if i is mids.length - 1
              i++

        getTaxonomyTree: (vid, callback) => # FIXME: empty result
          @serviceClass.service "taxonomy.getTree", {'vid':vid,'parent':undefined,'max_depth':undefined}, (data) =>
            @application.model.vocabularies[vid] = new Object(data)
            callback.call @application, data, vid

        getTaxonomyTrees: (vids, callback) =>
          i = 0
          for p of vids
            @getTaxonomyTree vids[p], (data) ->
              callback.call @application, vids  if i is vids.length - 1
              i++

        getBook: (bid, callback) =>
          nids = []
          nodesData = {}
          node = {}
          model = @model
          service = @serviceClass
          @serviceClass.service "site.getBook",
            bid: bid, (data) ->
                book = data
                model.books[bid] = book
                # preload all book nodes
                nids.push(bid)
                for k of book
                  below = book[k].below
                  for kk of below
                    nids.push Number(below[kk].link.href.split("/")[1])
                    for kkk of below[kk].below
                      nid = Number(below[kk].below[kkk].link.href.split("/")[1])
                      nids.push nid
                service.service "site.getNodes",nids: nids, (nodesData) ->
                  for node of nodesData
                    model.nodes[nodesData[node].nid] = nodesData[node]
                  callback.call(@application)

        getBooks: (bids, callback) =>
          i = 0
          for p of bids
            @getBook bids[p], () ->
              callback.call @application, bids  if i is bids.length - 1
              i++
                  
        parseNodeBody: (body) ->
            "" + body.replace(/(\r\n|\n|\r)/g, "<br>") + ""
            #"<p>" + body.replace(/(\r\n|\n|\r)/g, "<br>") + "</p>"

        saveModelToFile: (model,file)->
          domain = self.appSettings.domain
          subdomain = self.appSettings.domain
          if domain.match "www."
            subdomain = "default"
          #url = "sites/" + subdomain + "/modules/app_client/www/data/" + file
          url = file
          data = {}
          data.siteParams = model.siteParams
          data.nodes = model.nodes
          data.books = model.books
          data.views = model.views
          data.menus = model.menus
          data.vocabularies = model.vocabularies
          $.post "http://" + domain + "/sites/all/modules/app_server/data.php",
                data:
                            json: JSON.stringify(data)
                            file: url
                      , ((returnObj) ->
                        console.log "data written:" + returnObj
                      ), "json"
                      false

        getBookLinks: (data) ->
          gridData = []
          for k of data
            below = data[k].below
          for k of below
            item = {}
            for kk of below[k]
              link = below[k].link
              item = @application.model.nodes[Number(link.href.split("/")[1])]
            gridData.push item
          gridData