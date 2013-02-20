{ exec } = require 'child_process'

task 'spec:client', 'Run all specs in spec/client', ->
  exec 'NODE_ENV=test jasmine-headless-webkit --color', (error, stdout) ->
    console.log stdout
    throw error if error

task 'spec:server', 'Run all specs in spec/server', ->
  exec 'NODE_ENV=test ./node_modules/.bin/jasmine-node --coffee spec/lib', (error, stdout) ->
    console.log stdout
    throw error if error

task 'spec', 'Run all client and server specs', ->
  invoke 'spec:client'
  invoke 'spec:server'

task 'nodemon', 'run the server with nodemon', ->
  coffee = exec "./node_modules/.bin/nodemon -e coffee index.js"
  coffee.stdout.pipe process.stdout, end: false
  coffee.stderr.pipe process.stderr, end: false
