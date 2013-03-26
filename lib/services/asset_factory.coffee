_    = require 'underscore'
fs   = require 'fs'
rack = require 'asset-rack'

class AssetFactory
  config:
    js:
      mimetype: 'text/javascript'
      assetClass: rack.SnocketsAsset
      extensions: [ 'js', 'coffee' ]
    css:
      mimetype: 'text/css'
      assetClass: rack.LessAsset
      extensions: [ 'css', 'less' ]

  constructor: (@assetDir, @env) ->

  configFor: (type) =>
    config = @config[type]
    throw "Unknown asset type: #{type}" unless config?
    config

  create: (type, name, contents) =>
    config = @configFor type
    assetOpts =
      url: "/#{type}/#{name}.#{type}"
      hash: @env != 'development'
    if contents?
      assetOpts.contents = contents
      assetOpts.mimetype = config.mimetype
    else
      assetOpts.filename = @filename type, name

    assetClass = if contents? then rack.Asset else config.assetClass
    new assetClass assetOpts

  filename: (type, name) =>
    basename = "#{@assetDir}/#{type}/#{name}"
    for ext in @configFor(type).extensions
      return "#{basename}.#{ext}" if fs.existsSync "#{basename}.#{ext}"
    throw "Cannot find file: #{basename}.#{type}"

  basename: (type, filename) =>
    exts = _(@configFor(type).extensions).join '|'
    filename.replace("#{@assetDir}/#{type}/", '').replace(///\.(#{exts})$///, '')

module.exports = AssetFactory
