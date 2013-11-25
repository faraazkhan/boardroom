sinon = require 'sinon'

ApplicationController = require '../../../lib/controllers/application'

class Response
  writeHead: ->
  write: ->
  end: ->

describe 'ApplicationController', ->
  beforeEach ->
    @response = sinon.createStubInstance Response
    @app = new ApplicationController

  describe '#throw404', ->
    beforeEach ->
      @app.throw404 @response

    it 'sets the appropriate status-code/content-type', ->
      statusCode = 404
      headers = {'Content-Type': 'text/plain'}
      expect(@response.writeHead.calledWith(statusCode, headers)).toBeTruthy()

    it 'sets the body to "404 Not Found"', ->
      expect(@response.write.calledWith('404 Not Found\n')).toBeTruthy()

    it 'ends writing the response', ->
      expect(@response.end.called).toBeTruthy()

  describe '#throw500', ->
    beforeEach ->
      @app.throw500 @response, {stack: 'Contrived Stack Trace!'}

    it 'sets the appropriate status-code/content-type', ->
      statusCode = 500
      headers = {'Content-Type': 'text/plain'}
      expect(@response.writeHead.calledWith(statusCode, headers)).toBeTruthy()

    it 'sets the body to 500 error + error stack trace', ->
      status = '500 Error\n'
      body = 'Contrived Stack Trace!'
      expect(@response.write.getCall(0).calledWith(status)).toBeTruthy()
      expect(@response.write.getCall(1).calledWith(body)).toBeTruthy()

    it 'ends writing the response', ->
      expect(@response.end.called).toBeTruthy()
