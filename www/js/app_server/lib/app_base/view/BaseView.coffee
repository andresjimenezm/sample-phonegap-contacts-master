define (require, exports, module) ->
    backbone = require('backbone')
    BaseController = require('app_base/controller/BaseController');
    Util = require("util/Util")

    BaseView = Backbone.View.extend(
        debug: on
        type: 'view'
        name: null
        autoRender: off
        rendered: no
        model: {}
        appSettings: {}
        #template: -> '<h3><%= siteParams.site_name %></h3>' 

        initialize: (options = {el: "body",callback: @initApp,appSettings: undefined,config_file: undefined})->
            @options = options
            @el = @options.el
            @uid = 'app_view_'+@cid
            @name = @name or @constructor.name
            window[@uid] = @
            @callback = @initApp
            if options.callback != undefined
                @callback = @options.callback
            if options.appSettings != undefined
                @appSettings = options.appSettings
            if options.config_file != undefined
                @config_file = options.config_file
            @isOnTouchDevice = @checkForTouchDevice()
            if @isOnTouchDevice
              require ["util/fastclick.min"],(FastClick) -> 
                new FastClick(document.body)
            AppRouter = Backbone.Router.extend({
                routes: {
                    "*hashtag": "defaultRoute" # matches http://example.com/#anything-here
                }
            });
            @util = Util
            @app_router = new AppRouter;
            @controller = new BaseController({view:@,callback:@callback, config_file:@config_file, cid:@cid})
            window.console = window.console or (->
              c = {}
              c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile = c.clear = c.exception = c.trace = c.assert = ->
              c
            )()
            $(window).bind 'resize', @onResize
            @startDebugging() if @debug is on
            @render() if @autoRender is on
            @trigger "#{@cid}:initialize", @

        render: ->
            @trigger "#{@cid}:render:before", @
            @$el.attr('data-cid', @cid)
            #@html @template(@getRenderData())
            @rendered = yes
            @trigger "#{@cid}:render:after", @
            @

        setModel: (model) ->
            @model = model

        getRenderData: ->
            @model?.toJSON()

        isOnline: ->
            if window.navigator.onLine
              return true
            else
              return false

        #todo:
        showSpinner: ($el = $('.spinner')) ->
            $('.spinner').delay(200).show()

        hideSpinner: ($el = $('.spinner')) ->
            $('html').css('background','url()') # remove spinner
            $('.spinner').hide()

        onResize: (e) ->
            # override in subclasses

        destroy: (keepDOM = no) ->
            @trigger "#{@cid}:destroy:before", @
            if keepDOM then @dispose() else @remove()
            @model?.destroy()
            @trigger "#{@cid}:destroy:after", @

        startDebugging: ->
            @on "#{@cid}:initialize", -> console.log "Initialized #{@name}", @
            @on "#{@cid}:render", -> console.log "Rendered #{@name}", @
            @on "#{@cid}:update", -> console.log "Updated #{@name}", @
            @on "#{@cid}:destroy", -> console.log "Destroyed #{@name}", @

        checkForTouchDevice: ->
            (typeof(window.ontouchstart) != 'undefined') ? true : false;

        getJSON: (url, callback)  ->
            @controller.getJSON url, callback

        getJSONP: (url, callback) =>
            #@controller.getJSONP url, callback
            _this = @
            $.ajax
                url: url
                dataType: "jsonp"
                cache: true
                #jsonp: 'onJsonp',
                jsonpCallback: "JsonWrapping"
                success: (result) ->
                    callback.call _this, result
                error: (a, b, c) ->
                    console.log "jsonp load failed: "+url

        getXML: (url, callback) ->
          $.ajax
            type: "GET"
            url: url
            dataType: "xml"
            success: (xml) ->
              callback.call this, xml

        loadIframe: (url, $target, w, h, callback) ->
          id = 'iframe-'+ String(Math.random()).substring(6)
          $target.html '<iframe class="iframe-wrapper" id="'+id+'" name="'+id+'" marginwidth="0px" marginheight="0px"></iframe>'
          $target.css('margin',0).css('padding',0)
          $iframe = $("#"+id)
          $iframe.attr("width", w).attr("height", h).attr("frameborder", "0").attr("src",url).attr("allowTransparency","true")
          $iframe.attr('sandbox','allow-same-origin allow-scripts allow-top-navigation allow-forms')
          #$iframe.attr('seamless',true)
          $iframe.css("visibility", "hidden").css('margin',0).css('padding',0)
          $iframe.load ->
            $iframe.css "visibility", "visible"
            iframe = null
            if url.match(window.document.location.host) or !url.match('http') # cross domain check
              iframe = $iframe[0].contentWindow.document or $iframe[0].contentDocument
            callback.call @, iframe, id

        log:(args) ->
          if @appSettings.debug == true
            window.console.log args

        # jQuery Shortcuts
        html: (dom) ->
            @$el.html(dom)
            @trigger "#{@cid}:#{if @rendered then 'update' else 'render'}", @
            @$el

        append: (dom) ->
            @$el.append(dom)
            @trigger "#{@cid}:#{if @rendered then 'update' else 'render'}", @
            @$el

        prepend: (dom) ->
            @$el.prepend(dom)
            @trigger "#{@cid}:#{if @rendered then 'update' else 'render'}", @
            @$el

        after: (dom) ->
            @$el.after(dom)
            @trigger "#{@cid}:update", @
            @$el

        before: (dom) ->
            @$el.after(dom)
            @trigger "#{@cid}:update", @
            @$el

        css: (css) ->
            @$el.css(css)
            @trigger "#{@cid}:update", @
            @$el

        find: (selector) ->
            @$el.find(selector)

        delegate: (event, selector, handler) ->
            handler = selector if arguments.length is 2
            handler = (handler).bind @
            if arguments.length is 2
                @$el.on event, handler
            else
                @$el.on event, selector, handler
        
    )
    module.exports = BaseView