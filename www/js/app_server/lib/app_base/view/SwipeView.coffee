define (require, exports, module) ->

    swipe = require('vendor/swipe-js/swipe.min')

    module.exports = class SwipeView

        constructor: (options)->
            @options = options
            @isOnTouchDevice = @checkForTouchDevice()
            @hasNav = true
            if options.hasNav != undefined
                @hasNav = @options.hasNav
            if options.model != undefined
                @model = @options.model
            @render(@model,@options.template)

        render: (model,tpl) ->
          $target = $('#'+@options.target)
          @compId = @options.target+'-gallery'
          @id = 'slider_'+ String(Math.random()).substring(3)
          @$el = $('#'+@id)
          length = model.length
          ul = '<ul>'
          $(model).each (i, itemData) ->
            # item template
            ul += tpl(itemData)
          ul += '</ul>'
          h = ''
          h += '<div id="'+@compId+'" class="swipe-navigator">'
          h += "<nav>"
          h += '<a href="#" class="prev" onclick="window.'+@id+'.prev();return false;"><em>-</em></a>'
          # pager nav
          h += "<span class=\"position\">"
          i = 0
          while i < length
            if i is 0
              h += "<em class=\"on\">&bull;</em>"
            else
              h += "<em>&bull;</em>"
            i++
          h += "</span>"
          h += '<a href="#" class="next" onclick="window.'+@id+'.next();return false;"><em>-</em></a>'
          h += '</nav>'
          # slider
          h += '<div id="'+@id+'" class="swipe-slider">'
          h += ul
          h += "</div>"
          h += "</div>"
          $target.html h
          @bullets = $("#"+@compId+" .position em")
          # init swipe
          @swipeComponent = new Swipe(document.getElementById(@id),
            callback: (e, pos) =>
              i = @bullets.length
              @bullets[i].className = " "  while i--
              @bullets[pos].className = "on"
              #fixme:
              $(@).trigger('change',@)
          )
          window[@id] = @swipeComponent
          if @hasNav == false
            $("#"+@compId+" nav").css('display','none')
            $("#"+@compId+" .next").css('display','none')
            $("#"+@compId+" .prev").css('display','none')
          $("#"+@compId).hide(0).delay(200).show(300)
          $("#"+@id+" li").bind "click", @options.clickHandler

        ###swipeCallback: (e,pos) ->
            $(@).trigger('change')
            i = @bullets.length
            @bullets[i].className = " "  while i--
            @bullets[pos].className = "on"###

        next: ->
            @swipeComponent.next()

        prev: ->
            @swipeComponent.prev()

        slide: (index, duration) ->
            @swipeComponent.slide(index, duration)

        getPos: ->
            @swipeComponent.getPos()

        setPos: (index, duration) ->
            @slide(index, duration)

        checkForTouchDevice: ->
            (typeof(window.ontouchstart) != 'undefined') ? true : false;

        getRenderData: ->
            @model?.toJSON()

        onResize: (e) ->
            # override in subclasses
