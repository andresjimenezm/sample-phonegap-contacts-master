define (require, exports, module) ->
  module.exports = MediaController
  createJs = require(['createjs/preloadjs-0.2.0.min','createjs/soundjs-0.3.0.min'])
  self = {}

  class MediaController
  
	  constructor: (options = {app: null, preload_manifest: undefined, callback: null, media_root: ''}) ->
      self = @
      @options = options
      @media_root = options.media_root
      @edgeComps = []
      @loadedEdgeComps = []
      @easelComps = []
      @loadedEaselComps = []
      @images = {}
      @sounds = {}
      @xml = {}
      @json = {}
      @app = options.app
      @init()

    init: =>
      if window.images == undefined
        window.images = {}
      if window.sounds == undefined
        window.sounds = {}
      if self.options.preload_manifest != undefined and self.options.preload_manifest.length != 0
        self.preloadAssets self.options.preload_manifest, self.options.callback
      else
        self.options.callback.call null, self

    loadEdgeComp: ($el, compId, callback) ->
      $el.html "<div class=\"edge-wrapper\"><div id=\"Stage_" + compId + "\" class=\"" + compId + "\"></div></div>"
      $(".edgeLoad-" + compId).css display: "none"
      edgejs = @media_root+compId + "_edgePreload.js"
      require [edgejs], ->
        #console.log self.cb + ' # FIXME: edge bootstrapCallback :: '+ compId + ' :: ' + AdobeEdge
        AdobeEdge.bootstrapCallback (compId) ->
          console.log '# edge bootstrapCallback :: '+ AdobeEdge.getComposition(compId) + '  : sym='+document.sym
          if self.loadedEdgeComps[compId] is undefined
            self.loadedEdgeComps[compId] = AdobeEdge.getComposition(compId)
          callback.call self, document.sym, compId

    loadEaselComp: ($el, compId, callback,stagewidth,stageheight,media_root='') =>
      $el.html "<div class=\"easel-wrapper\"><canvas id=\"canvas_" + compId + "\" class=\"" + compId + "\"></canvas></div>"
      preload = @media_root + compId + ".js"
      require [preload], ->
        canvas = document.getElementById("canvas_" + compId)
        exportRoot = new lib[compId]()
        stage = new createjs.Stage(canvas)
        stage.addChild exportRoot
        stage.update()
        createjs.Ticker.setFPS 24
        createjs.Ticker.addListener stage
        callback.call self.app, compId, exportRoot, stagewidth, stageheight

    loadIframe: (url, $target, w, h, callback) ->
      id = 'iframe-'+ String(Math.random()).substring(6)
      $target.html '<iframe class="iframe-wrapper" id="'+id+'" name="'+id+'" marginwidth="0px" marginwheight="0px"></iframe>'
      $target.css('margin',0).css('padding',0)
      #$iframe = $target.find(".iframe-wrapper")
      $iframe = $("#"+id)
      $iframe.attr("width", w).attr("height", h).attr("frameborder", "0").attr("src",url)
      $iframe.css("visibility", "hidden").css('margin',0).css('padding',0)
      $iframe.load ->
        $iframe.css "visibility", "visible"
        iframe = null
        if url.match(window.document.location.host) or !url.match('http') # cross domain check
          iframe = $iframe[0].contentWindow.document or $iframe[0].contentDocument
        callback.call null, iframe, id

    preloadAssets: (manifest,callback) =>
      if manifest.length == 0
	      callback.call self, self
	      return
      for p of manifest
        manifest[p].src = self.media_root + manifest[p].src
      loader = new createjs.PreloadJS(false)
      loader.installPlugin createjs.SoundJS
      loader.onFileLoad = self.handleFileLoad
      loader.onComplete = @onAssetsLoaded
      loader.loadManifest manifest

    onAssetsLoaded: =>
      self.options.callback.call null, self


    handleFileLoad: (o) ->
      window.images[o.id] = self.images[o.id] = o.result  if o.type is "image"
      window.sounds[o.id] = self.sounds[o.id] = o.result  if o.type is "sound"

    playSound:(name, loops) ->
      createjs.SoundJS.play name, createjs.SoundJS.INTERRUPT_EARLY, 0, 0, loops

    ###extendCreateJs: ->
      window.createjs.Bitmap::setWidth = (w) ->
        return  if @image.width is 0
        @scaleX = w / @image.width
      window.createjs.Bitmap::setHeight = (h) ->
        return  if @image.height is 0
        @scaleY = h / @image.height
      window.createjs.MovieClip.prototype.move = (x, y) ->
        @x = x
        @y = y
      window.createjs.MovieClip.prototype.hide = (time=0.3) ->
        TweenLite.to(@,time,{alpha:0,onComplete: -> this.visible=false})###


            