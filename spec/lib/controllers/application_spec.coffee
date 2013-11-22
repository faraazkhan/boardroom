sinon = require 'sinon'

ApplicationController = require '../../../lib/controllers/application'

class Response
  writeHead: ->
  write: ->
  end: ->

describe 'ApplicationController', ->
  describe '#throw404', ->
    beforeEach ->
      @response = sinon.createStubInstance Response

      app = new ApplicationController
      app.throw404 @response

    it 'sets the appropriate status-code/content-type', ->
      statusCode = 404
      headers = {'Content-Type': 'text/plain'}
      expect(@response.writeHead.calledWith(statusCode, headers)).toBeTruthy()

    it 'sets the body to "404 Not Found"', ->
      expect(@response.write.calledWith('404 Not Found\n')).toBeTruthy()

    it 'ends writing', ->
      expect(@response.end.called).toBeTruthy()
