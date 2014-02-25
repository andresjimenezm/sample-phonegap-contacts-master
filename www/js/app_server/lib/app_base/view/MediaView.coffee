define (require, exports, module) ->
  self = undefined
  backbone = require("backbone")
  MediaController = require("app_base/controller/MediaController")
  EdgeView = require("app_base/view/EdgeView")
  EaselView = require("app_base/view/EaselView")

  MediaView = Backbone.View.extend(
    el: "body"
    className: "media-view"
    events: {}

    initialize: (options) ->
      self = this
      @onResize()
      #@loadMedia(options)

    loadMedia: (options) ->
      if options.type.match('edge')
        @loadEdge options
      if options.type.match('easel')
        @loadEasel options

    loadEdge: (options) ->
      uid = 'media_'+String(Math.random()).substring(6)
      @[uid] = new EdgeView(options)

    loadEasel: (options) ->
      uid = 'media_'+String(Math.random()).substring(6)
      @[uid] = new EaselView(options)

    onResize: (e) ->
      self.sw = parseInt($(window).width())
      self.sh = parseInt($(window).height())

    destroy: ->
  )
  module.exports = MediaView