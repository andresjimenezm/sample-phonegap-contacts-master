define (require, exports, module) ->

    BaseView = require('app_base/view/BaseView')
    self = {}

    module.exports = class DrupalAppView extends BaseView

        initService: (callback) ->
          self = @
          @callback = callback
          @domain = @appSettings.domain
          @subdomain = @appSettings.domain
          @subdomain = "default" if @domain.match("www.")
          @app_root = document.location.href.substring(0,document.location.href.lastIndexOf('/'))+"/"
          @app_root = @appSettings.app_root if @appSettings.app_root != undefined
          @baseURL = @app_root
          if @appSettings.online == true
            #@baseURL = "http://"+@domain+"/sites/"+@subdomain+"/modules/app_client/www-built/"
            @baseURL = "http://"+@domain+"/sites/"+@subdomain+"/modules/app_client/www/"
          @appSettings.baseURL = @baseURL
          @online = @appSettings.online
          #@online = @isOnline()
          if @online is true
            @log "live data"
            @getLiveSiteData @onLiveSiteData
          else
            @getStaticSiteData @baseURL+"data/site.jsonp", @onStaticSiteData
         
        getLiveSiteData: (callback) ->
          self = @
          self.drupal.getParams (data) ->
            # get menus +nodes
            self.drupal.getMenus self.appSettings.preload_drupal_menus.split(","), (mids) ->
              nids = []
              for p of mids
                menu = self.model.menus[mids[p]]
                for p of menu
                  nids.push menu[p].link_path.split("/")[1]  if menu[p].link_path.match("node/")
              self.drupal.getNodes nids, (data) ->
                # get books +  nodes
                self.drupal.getBooks self.appSettings.preload_drupal_books.split(","), (bids) ->
                  # FIXME: get taxonomy vocabularies: FIXME
                  self.drupal.getTaxonomyTrees self.appSettings.preload_drupal_vocabularies.split(","), (vids) ->
                    # all data loaded: callback
                    callback.call self, self.model

        getStaticSiteData: (dataFile, callback) ->
          @appSettings.dataFile = dataFile
          @log('static dataFile = '+dataFile)
          @getJSONP dataFile, (data) =>
            @model.siteParams = data.siteParams
            @model.nodes = data.nodes
            @model.menus = data.menus
            @model.books = data.books
            @model.views = data.views
            @model.vocabularies = data.vocabularies
            callback.call @, dataFile, data

        onLiveSiteData: (service_data) ->
          if @util.queryVars().update is "site" or window.location.host.match(":8888") # update
            @saveSiteData service_data
          @callback.call @, @model

        onStaticSiteData: (data) ->
          self = @
          # todo: ?? update
          if self.util.queryVars().update is "site" or window.location.host.match(":8888") #or window.location.host.match(":54321")
            self.updateServerData()
          @callback.call self, self.model

        updateServerData: ->
          @getLiveSiteData (service_data) ->
            @saveSiteData service_data

        saveSiteData: (data) -> # update server static files
          self = @
          #self.drupal.saveModelToFile data, "sites/" + self.subdomain + "/modules/app_client/www/data/site.json"
          self.drupal.saveModelToFile data, "sites/" + self.subdomain + "/modules/app_client/wwwSource/data/site.json"
          url = 'http://'+self.domain+'/sites/all/modules/app_server/data.php' # appsettings jsonp copy
          #url += '?file_to_jsonp=sites/'+self.subdomain+'/modules/app_client/www/appsettings.json'
          url += '?file_to_jsonp=sites/'+self.subdomain+'/modules/app_client/wwwSource/appsettings.json'
          $.ajax
              type: "GET"
              url: url
              success: (response) ->
                console.log response

        onResize: ->
          #self.appSettings.sw = parseInt($(window).width())
          #self.appSettings.sh = parseInt($(window).height())

        onHashChange: ->
          console.log "hashchange :: "+window.location.hash