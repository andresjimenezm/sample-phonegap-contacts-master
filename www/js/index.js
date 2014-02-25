// node tools/r.js -o tools/build.js

(function() {
  define(function(require, exports, module) {
    require('greensock/TweenMax.min')
    require('vendor/swfobject')
    var BaseView = require('app_base/view/BaseView'),
        //node_tpl = require('text!templates/test.tpl'),
        self,

        // sample selector: edeldruk
        
        AppView = BaseView.extend({
          el: '#samples',
          initApp: function (app){
            Backbone.history.start();
            self = app
            var nid = 281 // test: en
            var nid = 322 // test: de
            if(self.util.queryVars().nid){
              nid = self.util.queryVars().nid
            }
            // get node
            app.getJSONP('http://www.edeldruk.eu/?q=services/jsonp&method=node.get&nid='+nid+'&api_key=be62356c708411c39a4e167e4dd00222&callback=JsonWrapping',function(result){
                self.node = result.data
                // intro page render
                self.renderNode(result)
                $('.node .body').append('<img src="assets/images/view-samples-start.jpg"></img')
                // get view
                app.getJSONP(self.appSettings.viewFeed,app.renderApp)
            })
            app.onResize()
          },
          renderApp: function(result){
            $('html').css('background','url() #000')  // remove spinner
            $('#page-wrapper').css('visibility','visible').hide().fadeIn(1000)
            var data = self.data = result.data
            self.pagesData = []
            self.renderTaxonomySelect(data)
            self.start()
          },
          start: function(e){
            //$(e.target).unbind('click',self.start)
            $('#select').selectedIndex=1
            $('#select').trigger('change')
          },
          renderNode: function(result){
              var node = result.data
              $('.node .title').html('<h2 class="title">'+node.title+'</h2>')
              $('.node .body').html(node.body)
              if(node.type=='sample'){
                $('.node .body').html('<div>'+node['field_omschrijving_'+self.node.language][0].value+'</div><div id="ani"></div>')
                $('#ani').html('')
                _.each(node.field_image,function(image,i){
                  if(image.filepath!=undefined){
                    $('#ani').html('<img src="'+self.appSettings.drupalDomain+image.filepath+'"></img')
                    $("#ani img").bind("load", function () { $(this).fadeIn() });
                  }
                })
              }
              TweenMax.from($('.node'),1,{css:{opacity:0}})
          },
          renderPager: function(data){
             var i = 0
             var max = 12
             var pages = self.pages = []
             var total, page
             $(data).each(function(count,node){
                page = Math.floor(count/max)
                pages[page]=[]
                node.page = page
                total = count
             })
             $(data).each(function(count,node){
               pages[node.page].push(node)
             })
             self.$el.find('#pager ul').html('')
             if(pages.length > 1){
             $(pages).each(function(count,node){
                self.$el.find('#pager ul').append('<li class="pager-item" data-page="'+count+'">'+(count+1)+'</li>')
                self.$el.find('#pager ul li').each(function(i){
                   $(this).bind('click',function(){
                      self.renderList(pages[$(this).attr('data-page')])
                   })
                })
             })
             }
             self.renderList(pages[0])
          },
          renderList: function(data){
            var $el = $('#samples nav')
            $el.html('')
            var h = '<ul id="samplelist">'
            $(data).each(function(count,node){
                var thumb = self.appSettings.drupalDomain+'sites/default/files/imagecache/sample_thumbnail/'+node.field_image[0].filepath
                //h+='<li data-nid="'+node.nid+'">'+node.title+'</li>'
                h+='<li data-nid="'+node.nid+'"><img src="'+thumb+'" data-nid="'+node.nid+'"></img></li>'
            })
            h+='</ul>'
            $el.append(h)
            $el.find('li').each(function(i){
                $(this).bind('click',self.onListItemClick)
                TweenMax.from($(this),0.5,{opacity:0,delay:i*0.2})
            })
            //self.renderNode({data:data[0]})
          },
          onListItemClick: function(e){
              var nid = $(e.target).attr('data-nid')
              // fixme: set active li class
              $('#samples nav ul li').each(function(i){
                 $(this).removeClass('selected').css('border','0px solid #000')
                 if($(this).attr('data-nid')==nid){
                    $(this).addClass('selected').css('border','0px solid #000')
                 }
              })
              self.getJSONP('http://www.edeldruk.eu/?q=services/jsonp&method=node.get&nid='+nid+'&api_key=be62356c708411c39a4e167e4dd00222&callback=JsonWrapping',self.renderNode)
          },
          renderTaxonomySelect: function(data){
            var tids= []
            var names= []
            var selectProvider = []
            _.each(data,function(node,i){
              for (var p in node.taxonomy) {
                tids.push(node.taxonomy[p].tid);
                names.push(node.taxonomy[p].name);
              }
            })
            names=_.unique(names);
            tids=_.unique(tids);
            _.each(tids,function(tid,i){
              selectProvider.push({label:names[i],data:tid})
            })
            var h = '<option value="none">Select a category</option>'
            _.each(selectProvider,function(item,i){
              h+='<option value="'+item.data+'">'+item.label+'</option>'
            })
            $('#select').html(h).bind('change',self.select_ChangeHandler)
            self.selectProvider=selectProvider
            self.tids = tids
            if(tids.length==1){
               $('#select').hide()
            }
          },
          select_ChangeHandler: function(e){
            $('#select option').each(function(i){
              if($(this).attr('value')=='none'){$(this).remove()}
            })
            var listProvider = []
            _.each(self.data,function(node,i){
              for (var p in node.taxonomy) {
                if(node.taxonomy[p].tid==self.tids[e.target.selectedIndex]){
                  listProvider.push(node)
                }
              }
            })
            //self.log(listProvider)
            self.renderPager(listProvider)
          },
          onResize: function(e){
              self.sw = parseInt($(window).width())
              self.sh = parseInt($(window).height());
          }
      });
      return module.exports = AppView;
  });
}).call(this);