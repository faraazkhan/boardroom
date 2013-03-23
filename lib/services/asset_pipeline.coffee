_        = require 'underscore'
fs       = require 'fs'
rack     = require 'asset-rack'
path     = require 'path'
Fiber    = require 'fibers'
Snockets = require 'snockets'
logger   = require './logger'

assetDir = path.resolve "#{__dirname}/../../assets"
development = ( process.env.NODE_ENV ? 'development' ) == 'development'

class AssetRack extends rack.Rack
  handle: (request, response, next) =>
    Fiber =>
      response.locals.css = @css
      response.locals.js = @js
      super request, response, next
    .run()

  js: (name) =>
    if development
      filename = @jsFilename name
      files = new Snockets().getCompiledChain filename, { async: false }
      tags = []
      for file in files
        subname = file.filename.replace("#{assetDir}/js/", '').replace(/\.(js|coffee)$/, '')
        @findOrCreateAsset subname, 'js', file.js
        tag = @tag "/js/#{subname}.js"
        tags.push tag
      tags.join ''
    else
      @findOrCreateAsset name, 'js'
      @tag "/js/#{name}.js"

  css: (name) =>
    @findOrCreateAsset name, 'css'
    @tag "/css/#{name}.css"

  findOrCreateAsset: (name, ext, content) =>
    fiber = Fiber.current
    complete = yielded = false
    asset = _(@assets).find (asset) -> asset.lookup == "#{name}.#{ext}"
    if asset?
      logger.debug -> "Found asset: #{name}.#{ext}"
      return asset
    else
      logger.debug -> "Creating asset: #{name}.#{ext}"
      done = false
      if content?
        asset = @createStaticAsset name, ext, content
      else
        asset = @createJSAsset name if ext == 'js'
        asset = @createCSSAsset name if ext == 'css'
      throw "Cannot find asset for: #{name}.#{ext}" unless asset?
      asset.rack = @
      asset.lookup = "#{name}.#{ext}"
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
        logger.debug -> "Asset compiled: #{name}.#{ext}"
        complete = true
        fiber.run() if yielded
      unless complete
        yielded = true
        Fiber.yield()
      asset

  createStaticAsset: (name, ext, content) =>
    mimetypes =
      js: 'text/javascript'
      css: 'text/css'
    new rack.Asset
      url: "/#{ext}/#{name}.#{ext}"
      contents: content
      hash: ! development
      mimetype: mimetypes[ext]

  createJSAsset: (name) =>
    new rack.SnocketsAsset
      url: "/js/#{name}.js"
      filename: @jsFilename name
      hash: ! development

  createCSSAsset: (name) =>
    new rack.LessAsset
      url: "/css/#{name}.css"
      filename: @cssFilename name
      hash: ! development

  jsFilename: (name) =>
    filename = "#{assetDir}/js/#{name}"
    ext = 'coffee' if fs.existsSync "#{filename}.coffee"
    ext = 'js'     if fs.existsSync "#{filename}.js"
    throw "Cannot find file: #{filename}.js|coffee" unless ext?
    "#{filename}.#{ext}"

  cssFilename: (name) =>
    filename = "#{assetDir}/css/#{name}.less"
    throw "Cannot find file: #{filename}" unless fs.existsSync filename
    filename

class AssetPipeline
  constructor: ->
    @middleware = new AssetRack []
    @middleware.on 'complete', -> ( logger.debug -> 'Asset pipelines complete' )
    @middleware.removeAllListeners 'error' # we'll do our own
    @middleware.on 'error', -> # do nothing, it all happens in the asset error handlers

  precompile: (args) =>
    Fiber =>
      @middleware.js js   for js in args.js
      @middleware.css css for css in args.css
    .run()

module.exports = new AssetPipeline()
