{ exec } = require 'child_process'

task 'spec:client', 'Run all specs in spec/client', ->
  exec 'NODE_ENV=test jasmine-headless-webkit', (error, stdout) ->
    console.log stdout
    throw error if error

task 'spec:server', 'Run all specs in spec/server', ->
  exec 'NODE_ENV=test ./node_modules/.bin/jasmine-node --coffee spec/lib', (error, stdout) ->
    console.log stdout
    throw error if error

task 'spec', 'Run all client and server specs', ->
  invoke 'spec:client'
  invoke 'spec:server'
