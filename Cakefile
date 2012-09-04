{ exec } = require 'child_process'

task 'spec:server', ->
  exec 'NODE_ENV=test jasmine-node --coffee spec/', (_, stdout, _) ->
    console.log stdout
