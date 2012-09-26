request = require 'supertest'
jsdom = require 'jsdom'
url = require 'url'
$ = require 'jquery'
Router = require "#{__dirname}/../../../lib/router"
LoggedInRouter = require './../support/authentication'
Factory = require './../support/factories'

describe 'HomeController', ->
  describe '#index', ->
    describe 'when logged in', ->
      router = null

      beforeEach (done) ->
        router = new LoggedInRouter 'board-creator-1'
        Factory.createBundle 'typical', ->
          done()

      it 'shows my boards', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            done error if error?
            jsdom.env
              html: response.text
              done: (error, window) ->
                done(error) if error?
                expect(response.ok).toBeTruthy()
                expect($('#boards ul', window.document).length).toEqual 2
                expect($('#boards li', window.document).length).toEqual 2
                done()

    describe 'when logged out', ->
      router = null

      beforeEach ->
        router = new Router

      it 'redirects to the login page', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            done error if error?
            expect(response.redirects).toBeTruthy()
            redirect = url.parse response.headers.location
            expect(redirect.pathname).toEqual '/login'
            done()
