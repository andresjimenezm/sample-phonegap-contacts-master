define (require, exports, module) ->

    module.exports = class BaseController

        constructor: (options = {el: $("body"),callback: @initApp,config_file:'appsettings.json'}) ->
            @options = options
            @view = @options.view
            @appSettings = @view.appSettings
            #@appSettings = @parseAppSettings(@appSettings.appsettings)
            @config_file = @view.config_file
            if @options.config_file != undefined
              @loadAppsettings @options.config_file, @onAppsettingsLoaded
            else
              window.app_context_temp = @
              @onAppsettingsLoaded()

        onAppsettingsLoaded: ->
            self = window.app_context_temp
            if self.appSettings.cms == "drupal"
              require ["app_base/controller/DrupalController"],(DrupalController) -> 
                drupal = new DrupalController({app:self.view,callback:self.options.callback})
            else
              self.options.callback.call self.view, self.view

        loadAppsettings: (url, callbackFn) ->
      		  dataType = undefined
      		  window.app_context_temp = @
      		  if url.match(".json")
      		    dataType = "json"
      		    if url.match(".jsonp") or url.match("data.php?file_p")
      		      window.app_context_temp.getJSONP url, (data) ->
      		        appSettings = undefined
      		        p = undefined
      		        appSettings = window.app_context_temp.parseAppSettings(data.appsettings)
      		        for p of appSettings
      		          window.app_context_temp.appSettings[p] = new Object()
      		          window.app_context_temp.appSettings[p] = appSettings[p]
      		        callbackFn.call null
      		    else
      		      $.getJSON url, (data) ->
      		        appSettings = undefined
      		        p = undefined
      		        appSettings = window.app_context_temp.parseAppSettings(data.appsettings)
      		        for p of appSettings
      		          window.app_context_temp.appSettings[p] = new Object()
      		          window.app_context_temp.appSettings[p] = appSettings[p]
      		        callbackFn.call null
      		  if url.match(".xml")
      		    $.ajax
      		      type: "GET"
      		      url: url + "?" + Math.random()
      		      dataType: "xml"
      		      success: (xml) ->
      		        xml = xml
      		        $(xml).find("add").each ->
      		          key = undefined
      		          value = undefined
      		          key = undefined
      		          value = undefined
      		          key = $(this).attr("key")
      		          value = $(this).attr("value")
      		          value = Number(value)  if Number(value) and value isnt "true" and value isnt "false"
      		          value = 0  if value is "0"
      		          value = true  if value is "true"
      		          value = false  if value is "false"
      		          self.appSettings[key] = new Object()
      		          self.appSettings[key] = value
      		        callbackFn.call null

        parseAppSettings: (appsettings) ->
          key = undefined
          p = undefined
          tempObj = undefined
          value = undefined
          tempObj = {}
          for p of appsettings.add
            key = appsettings.add[p]["key"]
            value = appsettings.add[p]["value"]
            value = Number(value)  if Number(value) and value isnt "true" and value isnt "false"
            value = 0  if value is "0"
            value = true  if value is "true"
            value = false  if value is "false"
            tempObj[key] = value
          returnObj = {}
          for pp of tempObj
              returnObj[pp] = new Object()
              returnObj[pp] = tempObj[pp]
          returnObj

        getJSON: (url, callback)  ->
            $.ajax
                type: "GET"
                url: url
                dataType: "json"
                succes: (json) ->
                  callback.call this, json
                error: (a, b, c) ->
                  window.console.log "json load failed: "+url