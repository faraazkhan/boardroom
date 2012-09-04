{ exec } = require 'child_process'

task 'spec:client', 'Run all specs in spec/client', ->
  exec 'NODE_ENV=test jasmine-headless-webkit', (_, stdout) ->
    console.log stdout

task 'spec:server', 'Run all specs in spec/server', ->
  exec 'NODE_ENV=test jasmine-node --coffee spec/server', (_, stdout) ->
    console.log stdout

task 'spec', 'Run all client and server specs', ->
  invoke 'spec:client'
  invoke 'spec:server'
