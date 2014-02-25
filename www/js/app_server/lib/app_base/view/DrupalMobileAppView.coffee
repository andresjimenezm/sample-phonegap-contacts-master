# node tools/r.js -o tools/build.js
define (require, exports, module) ->

  BaseView = require 'app_base/view/DrupalAppView';
  MediaController = require 'app_base/controller/MediaController'
  jquerymobile = require 'jquerymobile'
  self = {}

  module.exports = class DrupalMobileAppView extends BaseView

    initJqueryMobile: (options) ->
      self = @
      $.support.cors = true
      @$mobile = $.mobile
      @$mobile.allowCrossDomainPages = true
      @$mobile.defaultPageTransition = "none"
      @appSettings.index_id = @appSettings.index_nid
      @appSettings.book_id = @appSettings.index_nid
      @initService @initMedia
      @currentNode = {nid:0}
      @previousNode = {nid:0}
      @edgeCompId = ''
      window.renderEdgeTemplate = (sym,compId)->
        self.renderEdgeTemplate(sym,compId)

    initMedia: =>
      @media = new MediaController(
        app: @
        preload_manifest: []
        media_root: @appSettings.media_root
        callback: @initDocument
      )

    initDocument: =>
      @setupRouter()
      Backbone.history.start()
      # FIXME:
      hash = window.location.hash
      if hash is ""
        window.location.hash = "#page-node-" + @appSettings.index_nid
        #window.location.hash = ""
      else
        # fixme: hotlinking page
        #window.location.hash = "" # hack
        #window.location.hash = hash
        #window.location.hash = "#page-node-" + @appSettings.index_nid

    setupRouter: =>
      @log 'setupRouter'
      @app_router.on "route:defaultRoute", (hashtag) =>
        if hashtag.match("page-node-")
          node = @model.nodes[hashtag.split('-')[2]]
          @hash = hashtag
          if node.nid != @currentNode.nid
            @prepareNode node
            @$mobile.changePage '#page-node-'+node.nid      
            @renderNode node

    prepareNode: (node) =>
      # ??? edge content
      #$temp = $('#Stage').remove()
      #@edgeContent = '<div id="Stage" class="'+@edgeCompId+'">'
      #@edgeContent += $temp.html();
      #@edgeContent += '</div>';
      #
      page_id = '#page-node-'+node.nid
      $(':jqmData(url="page-node-'+node.nid+'")').live "pageinit", (event) =>
        console.log 'pageinit: '+page_id
        @currentNode = node
        @$currentNodeRenderer = $(page_id+' .node-holder .node')
        @renderNode node
        # edge ??
        #$(".edge-wrapper").show(0)
        ###$("#Stage").delay(500).show(0)
        $("#Stage").children().delay(600).show(0) ###   
      document.title = self.model.siteParams.site_name+' :: '+node.title
      data = {node: node,meta: @model.siteParams,edgeStage:@edgeContent}
      if $(page_id).size()
        $(page_id).remove()
      @.append new EJS(url: @appSettings.path_to_ejs_templates+"/page.ejs").render(data)
      $(page_id+' .header').html new EJS(url: @appSettings.path_to_ejs_templates+"/header.ejs").render(data)
      $(page_id+' .node-holder').html new EJS(url: @appSettings.path_to_ejs_templates+"/node.ejs").render(data)
      $(page_id+' .footer').html new EJS(url: @appSettings.path_to_ejs_templates+"/footer.ejs").render(@drupal.getBookLinks(@model.books[@appSettings.book_id]))
      #$(page_id).live "pagecreate", (event) =>
        #console.log 'pagecreate : '+page_id

    renderEdgeTemplate: (sym) ->
        console.log 'default edge render'