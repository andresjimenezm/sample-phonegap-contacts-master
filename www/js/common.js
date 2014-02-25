// node tools/r.js -o tools/build.js
//The build will inline common dependencies into this file.
//For any third party dependencies, like jQuery, place them in the lib folder.

//Configure loading modules from the lib directory,
//except for 'app' ones, which are in a sibling directory.

requirejs.config({
    baseUrl: 'js/app_server/lib',
    paths: {
        templates: '../../../assets/templates',
        app_base: 'app_base',
        vendor: 'vendor',
        createjs: "vendor/createjs",
        greensock: "vendor/greensock"
    },
    shim: {
        backbone: {
            deps: ['jquery-min', 'underscore-min','vendor/modernizr.custom.min'],
            exports: 'Backbone'
        },
        underscore: {
            exports: '_'
        }
    }
});