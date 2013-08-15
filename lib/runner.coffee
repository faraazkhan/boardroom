cluster = require 'cluster'
sh = require 'execSync'

logger = require './services/logger'
logger.setLevel( process.env.LOG_LEVEL ? 'info' )

env = process.env.NODE_ENV ? 'development'
port = process.env.PORT ? 7777
cpus = process.env.CPUS ? 1
profile = process.env.PROFILE ? false
maxfiles = sh.exec('ulimit -n').stdout.trim()

start = () ->
  Boardroom = require './boardroom'
  new Boardroom({ env, port }).start()

if cluster.isMaster
  logger.warn -> 'Starting Boardroom'
  logger.warn -> "  env:      #{env}"
  logger.warn -> "  port:     #{port}"
  logger.warn -> "  cpus:     #{cpus}"
  logger.warn -> "  profile:  #{profile}"
  logger.warn -> "  maxfiles: #{maxfiles}  (via ulimit -n)"

  Migrator = require './services/migrator'
  migrator = new Migrator
  migrator.migrate (error) ->
    throw error if error?

    cpus = require('os').cpus().length if cpus == 'all'
    cpus = parseInt cpus

    if cpus == 1
      if profile && profile != 'false'
        profile = 5959 if profile == 'true' || profile == true
        require('look').start(profile)
      start()
      return

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

  start()
