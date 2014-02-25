define (require, exports, module) ->

    BaseModel = require('app_base/model/BaseModel');

    module.exports = class DrupalModel extends BaseModel
        defaults:
            nodes: []
            siteParams: {}
            menus: {}
            views: {}
            books: {}
            vocabularies: {}

        initialize: ->
            @nodes = []
            @siteParams = {}
            @menus = {}
            @views = {}
            @books = {}
            @vocabularies = {}
            #console.log "DrupalModel initialize"

        getTitle: ->
            @siteParams.site_name

        parseStaticData: (data) ->
            @siteParams = data.siteParams
            @nodes = data.nodes
            @menus = data.menus
            @views = data.views
            @books = data.books
            @vocabularies = data.vocabularies