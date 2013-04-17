_protected = require '../../../../lib/services/authentication/protected'

describe 'protected', ->
  describe 'given a request', ->
    url = '/a/url/path'
    request = undefined
    response = undefined
    next = undefined

    beforeEach ->
      request = { url }
      response = jasmine.createSpyObj 'response', ['redirect']
      next = jasmine.createSpy()

    describe 'when there is a user on the request', ->
      id = 123

      beforeEach ->
        request.user = { id }

        _protected request, response, next

      it "sets the user's id on the session", ->
        expect(request.session.user_id).toEqual id

      it "calls the next request handler", ->
        expect(next).toHaveBeenCalled()

    describe 'when there is no user on the request', ->
      beforeEach ->
        _protected request, response, next

      it 'captures the current request URL to the session', ->
        expect(request.session.urlToRedirectToOnLogIn).toEqual url

      it 'does not call the next handler', ->
        expect(next).not.toHaveBeenCalled()

      it 'redirects the request to login', ->
        expect(response.redirect).toHaveBeenCalledWith '/login'
