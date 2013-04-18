cluster = require 'cluster'

logger = require './services/logger'
logger.setLevel 'info'

# node.js clustering feature-flag
doCluster = false

start = ->
  Boardroom = require './boardroom'
  app = new Boardroom
  app.start()

if cluster.isMaster
  logger.warn -> 'Starting Boardroom'

  Migrator = require './services/migrator'
  migrator = new Migrator
  migrator.migrate (error) ->
    throw error if error?

    unless doCluster
      start { cluster: false }
      return

    cpus = require('os').cpus().length
    for n in [1..cpus]
      worker = cluster.fork()
      worker.ident = -> "Worker #{@id} (pid #{@process.pid})"

    cluster.on 'fork', (worker) ->
      logger.debug -> "#{worker.ident()} forked"

    cluster.on 'online', (worker) ->
      logger.debug -> "#{worker.ident()} online"

    cluster.on 'listening', (worker, address) ->
      logger.info -> "#{worker.ident()} listening"

    cluster.on 'exit', (worker, code, signal) ->
      logger.warn -> "Worker #{worker.process.pid} died (#{code}, #{signal})"
      cluster.fork()

else
  pipeline = require './services/asset_pipeline'
  pipeline.precompile
    js: [ 'login', 'index', 'application' ]
    css: [ 'application' ]

  start { cluster: true }