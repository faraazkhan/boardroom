io      = require 'socket.io-client'
program = require 'commander'
http    = require 'http'
cluster = require 'cluster'

random  = require './random'
Spy     = require './spy'
Monkey  = require './monkey'

doMaster = ->
  program
    .version('1.0')
    .option('-b, --board <id>', 'The id of the board (required)')
    .option('-n, --sessions [count]', 'Number of sessions you want to open [10]', parseInt, 10)
    .option('-e, --events [count]', 'Number of events per minute per session [60]', parseInt, 120)
    .option('-h, --host [name]', 'Host of the server to test [localhost]', 'localhost')
    .option('-p, --port [number]', 'Port of server to test [7777]', parseInt, 7777)
    .option('-E, --env [name]', 'Node environment (NODE_ENV) of server to test [development]', 'development')
    .option('-N, --servers [number]', 'Number of servers to test (multiple assumes port 7778, 7779, etc) [1]', parseInt, 1)
    .option('-w, --workers [number]', 'Number of load generating workers to use [1]', parseInt, 1)
    .parse(process.argv)

  unless program.board?
    program.outputHelp()
    process.exit 1

  console.log "Running load test on board #{program.board}"

  getsocketurl = (i = 0) ->
    port = program.port + (i % program.servers)
    "http://#{program.host}:#{port}/#{program.env}/boards/#{program.board}"

  gethttpurls = ->
    "http://#{program.host}:#{port}/boards/#{program.board}/warm" for port in [program.port...(program.port + program.servers)]

  sigintSem = 0
  process.on 'SIGINT', ->
    process.exit() if sigintSem > 0
    sigintSem += 1
    console.log "cleaning up..."
    worker.send({ cmd: 'stop' }) for worker in workers.w

  workers = { w: [] }
  workers.get = (i) -> workers.w[i % program.workers]
  workers.all = workers.w
  createWorkers = (spy) ->
    for i in [0...program.workers]
      worker = cluster.fork()
      worker.on 'message', (msg) ->
        spy.onConnect()              if msg.cmd == 'connect'
        spy.hit('send', msg.command) if msg.cmd == 'hit'
      workers.w.push worker

  startBanging = ->
    console.log "agitating #{program.sessions} monkeys in #{program.workers} workers..."
    console.log "  -> #{getsocketurl()}"
    spy = new Spy getsocketurl(), program.sessions, workers
    createWorkers spy
    for i in [0...program.sessions]
      worker = workers.get i
      worker.send
        cmd: 'new monkey'
        body:
          i: i
          board: program.board
          url: getsocketurl(i)
          events: program.events

  serverCount = 0
  cb = ->
    serverCount += 1
    startBanging() if serverCount == program.servers

  console.log "warming up #{program.servers} servers..."
  for url in gethttpurls()
    console.log "  -> #{url}"
    http.request(url, cb).end()

doWorker = ->
  sigintSem = 0
  process.on 'SIGINT', ->
    process.exit() if sigintSem > 0
    sigintSem += 1

  monkeys = []
  process.on 'message', (msg) ->
    cmd = msg.cmd
    if cmd == 'stop'
      ( monkey.stop() if monkey? ) for monkey in monkeys
    else if cmd == 'disconnect'
      i = msg.body
      monkeys[i].disconnect()
    else if cmd == 'new monkey'
      body = msg.body
      monkeys[body.i] = new Monkey(body.i, body.board, body.url, body.events)
    else if cmd == 'start'
      ( monkey.start() if monkey? ) for monkey in monkeys

if cluster.isMaster
  doMaster()
else
  doWorker()
