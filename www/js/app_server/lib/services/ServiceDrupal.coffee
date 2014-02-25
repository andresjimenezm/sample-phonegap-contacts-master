define (require, exports, module) ->

  module.exports = class ServiceDrupal

    constructor: (options) ->
      @options = options
      @gateway = options.gateway
      @_domain = options.domain
      @_sessid
      @_requireSession = options.requireSession
      @_key = options.key
      @_allowed_domain = options.allowed_domain
      @_serviceArgs="&callback=?"

    service: (service_method, args, success) ->
      self = this
      args = $.extend(
        method: service_method
      , args)
      args_done = {}
      for i of args
        args_done[i] = self.toJsonp(args[i])
      args_done["sessid"] = @_sessid  if @_requireSession is true and @_sessid isnt ""
      args_done["callback"] = "?"
      query = ""
      for i of args_done
        query += "&" + i + "=" + String(args_done[i]).replace(/"/g, "") # strip " characters
      # console.log self.gateway + query
      $.ajax
        type: "GET"
        url: self.gateway + query
        dataType: "json"
        success: (response) ->
          if response.status
            success response.data
          else
            self.onServiceError response
        error: @onServiceError

    connect: (callback) ->
      self = this
      self.service "system.connect", {}, (data) ->
        self.sessid = data.sessid
        if self._requireSession is true
          self._sessid = data.sessid
          self._serviceArgs = "&sessid=" + data.sessid + "&callback=?"
        else
          self._serviceArgs = "&callback=?"
        callback.call self, data


    siteGetParams: (callback) ->
      @service "site.getParams", {}, (data) ->
        callback.call this, data


    siteGetNodes: (nids, callback) ->
      @service "site.getNodes",
        nids: nids
      , callback

    nodeGet: (nid, callback) ->
      @service "node.get",
        nid: nid
      , callback

    nodesGet: (nids, callback) ->
      @service "site.getNodes",
        nids: nids
      , callback

    # FIXME: mid argument in jsonp_server module
    menuGet: (mid, callback) ->
      @service "menu.get",
        mid: mid
      , (data) ->
        callback.call this, data, mid

    viewsGet: (view_name, fields, callback) ->
      # FIXME: fields : bad result format
      # this.service("views.get",{view_name: view_name,fields: fields},function(data){
      #   callback.call(this,data,view_name)
      # });
      @service "views.get",
        view_name: view_name
      , (data) ->
        callback.call this, data, view_name

    # FIXME: bid argument in jsonp_server module
    bookGet: (bid, callback) ->
      @service "site.getBook",
        bid: bid
      , (data) ->
        callback.call this, data, bid

    toJsonp: (v) ->
      self = this
      switch typeof v
        when "boolean"
          (if v is true then "TRUE" else "FALSE")
        when "number"
          v
        when "string"
          "\"" + v + "\""
        when "object"
          # bugfix array object
          return "[" + v + "]"  if Object::toString.call(v) is "[object Array]"
          output = "{"
          for i of v
            output = output + i + ":" + self.toJsonp(v[i]) + ","
          output = output + "}"
          output
        else
          "null"

    onServiceError: (response) ->
      @error = response["data"]
      console.log "ERROR :: ServiceDrupal :: " + @error
      $(this).trigger "error"