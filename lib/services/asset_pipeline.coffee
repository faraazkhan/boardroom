rack = require 'asset-rack'
fs = require 'fs'
wrench = require 'wrench'
_ = require 'underscore'
pathutil = require 'path'
logger = require './logger'
Snockets = require 'snockets'

assetDir = pathutil.resolve "#{__dirname}/../../assets"
development = ( process.env.NODE_ENV ? 'development' ) == 'development'

class Rack extends rack.Rack
  handle: (request, response, next) =>
    response.locals.css = (name) => @tag "/css/#{name}.css"
    response.locals.js = @js
    super request, response, next

  js: (name) =>
    if development
      asset = _(@assets).find (asset) -> asset.filename.match ///\/#{name}\.(js|coffee)$///
      if asset
        snockets = new Snockets()
        files = snockets.getCompiledChain asset.filename, { async: false }
        tags = ( @tag file.filename.replace(assetDir, '').replace('.coffee', '.js') for file in files )
        tags.join ''
      else
        @tag "/js/#{name}.js"
    else
      @tag "/js/#{name}.js"

class AssetPipeline
  constructor: ->
    @middleware = new Rack @assets()
    @middleware.on 'complete', -> ( logger.debug -> 'Asset pipelines complete' )

  assets: ->
    assets = @jsAssets().concat @cssAssets()
    for asset in assets
      asset.on 'error', (err) ->
        logger.error -> "Error with asset: #{asset.url}"
        console.log err
    assets

  jsAssets: ->
    dir = assetDir + '/js'
    files = _(wrench.readdirSyncRecursive(dir)).select (file) -> file.match /\.(js|coffee)$/
    _(files).map (file) ->
      url = '/js/' + file.replace('.coffee', '.js')
      new rack.SnocketsAsset
        url: url
        filename: "#{dir}/#{file}"
        hash: ! development

  cssAssets: ->
    dir = assetDir + '/css'
    files = _(fs.readdirSync(dir)).select (file) -> file.match /^application.less$/
    _(files).map (file) ->
      url = '/css/' + file.replace('.less', '.css')
      new rack.LessAsset
        url: url
        filename: "#{dir}/#{file}"
        hash: ! development

module.exports = new AssetPipeline()
