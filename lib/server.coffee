cluster = require 'cluster'
cpus = require('os').cpus().length

logger = require './services/logger'
logger.setLevel 'info'

if cluster.isMaster
  logger.warn -> 'Starting Boardroom'

  Migrator = require './services/migrator'
  migrator = new Migrator
  migrator.migrate (error) ->
    throw error if error?
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
  Router = require './services/router'
  router = new Router
  router.start()
