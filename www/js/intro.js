(function() {
  define(function(require, exports, module) {
    var BaseView = require('app_base/view/BaseView'),
        tweenMax = require('greensock/TweenMax.min'),
        self

        AppView = BaseView.extend({
          el: '#intro',
          initApp: function (app){
            $('html').css('background','url() #000') // remove spinner
            self = app
            app.loadIframe('assets/intro.htm', $('#intro'), 960, 540, function(ifr){
                self.ifr=ifr
                $('iframe').attr('scrolling','no')
                $("html",ifr).css('overflow','hidden')
                $("body",ifr).css('padding',0).css('margin',0)
                // language buttons
                $("[id$=_flag]",ifr).each(function(i){
                    $(this).on('click',self.onClick).css('cursor','pointer')
                    TweenMax.from($(this),3,{opacity:0,delay:3.8})
                })
                // slogans animate
                $("#slogan1,#slogan2",ifr).hide(0)
                app.slogans = [$("#slogan1",ifr).attr('src'),$("#slogan2",ifr).attr('src')]
                _(app.swapImage).delay(2300)
                // image
                TweenMax.from($("#pic",self.ifr),2,{opacity:0,delay:0.4,yoyo:true})
            })
            app.onResize()
          },
          swapImage: function(){
            $el = $("#slogan1",self.ifr)
            $el.show(0).css('opacity','0')
            self.toggle = !self.toggle
            if(self.toggle){
              $el.attr('src',self.slogans[0])
            }else{
              $el.attr('src',self.slogans[1])
            }
            TweenMax.to($el,2,{opacity:1,delay:0,onComplete:function(){
                TweenMax.to($el,1.2,{opacity:0,delay:2,onComplete:self.swapImage})
            }})
          },
          onClick: function(e){
            var lang = $(e.target).attr('id').split('_')[0]
            // BUG: iOs safari: url's must be hard coded in Fireworks
            // if(lang=="nl"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/353");
            // }
            // if(lang=="en"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/357");
            // }
            // if(lang=="fr"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/358");
            // }
            // if(lang=="de"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/356");
            // }
            // if(lang=="it"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/359");
            // }
            // if(lang=="es"){
            //   self.getURL(self.appSettings.drupalDomain+lang+"/node/360");
            // }
          },
          getURL: function(url){
            window.parent.document.location = url
          },
          onResize: function(e){
            self.sw = parseInt($(window).width())
            self.sh = parseInt($(window).height());
          }
      });
      return module.exports = AppView;
  });
}).call(this);