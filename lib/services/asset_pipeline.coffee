_        = require 'underscore'
fs       = require 'fs'
rack     = require 'asset-rack'
path     = require 'path'
Fiber    = require 'fibers'
Snockets = require 'snockets'
logger   = require './logger'

AssetFactory = require './asset_factory'

class AssetRack extends rack.Rack
  constructor: ->
    @assetDir = path.resolve "#{__dirname}/../../assets"
    @env = process.env.NODE_ENV ? 'development'
    @factory = new AssetFactory @assetDir, @env
    super []

  handle: (request, response, next) =>
    response.locals.css = @css
    response.locals.js = @js
    _render = response.render
    response.render = (view, options, callback) ->
      Fiber => 
        _render.call response, view, options, callback
      .run()
    super request, response, next

  js: (name) =>
    type = 'js'
    if @env == 'development'
      filename = @factory.filename type, name
      files = new Snockets().getCompiledChain filename, { async: false }
      tags = []
      for file in files
        subname = @factory.basename type, file.filename
        @findOrCreateAsset type, subname, file.js
        tag = @tag "/js/#{subname}.js"
        tags.push tag
      tags.join ''
    else
      @findOrCreateAsset type, name
      @tag "/js/#{name}.js"

  css: (name) =>
    type = 'css'
    @findOrCreateAsset type, name
    @tag "/css/#{name}.css"

  findOrCreateAsset: (type, name, contents) =>
    ident = "#{name}.#{type}"
    fiber = Fiber.current
    complete = yielded = false
    asset = _(@assets).find (asset) -> asset.lookup == ident
    if asset?
      logger.debug -> "Found asset: #{ident}"
      return asset
    else
      logger.debug -> "Creating asset: #{ident}"
      done = false
      asset = @factory.create type, name, contents
      asset.rack = @
      asset.lookup = ident
      asset.removeAllListeners 'error' # we'll do our own
      asset.emit 'start'
      asset.on 'error', (err) ->
        logger.error => "Error with asset: #{@url}"
        console.log err
        complete = true
        fiber.run() if yielded
      asset.on 'complete', =>
        @assets.push asset if asset.contents?
        @assets = @assets.concat asset.assets if asset.assets?
        logger.debug -> "Asset compiled: #{ident}"
        complete = true
        fiber.run() if yielded
      unless complete
        yielded = true
        Fiber.yield()
      asset

class AssetPipeline
  constructor: ->
    @middleware = new AssetRack()
    @middleware.on 'complete', -> ( logger.debug -> 'Asset pipelines complete' )
    @middleware.removeAllListeners 'error' # we'll do our own
    @middleware.on 'error', -> # do nothing, it all happens in the asset error handlers

  precompile: (args) =>
    Fiber =>
      @middleware.js js   for js in args.js
      @middleware.css css for css in args.css
    .run()

module.exports = new AssetPipeline()
