{ User, Factory, Identity } = require "../support/model_test_support"

describe 'User', ->
  it "exists", ->
    expect(User).toBeDefined()

  describe "logging in", ->
    describe 'given an authenticated profile', ->
      identity = undefined

      beforeEach (done) ->
        Factory.build 'identity',
          { source: 'Twitter', sourceId: 'karimofthecrop' },
          (error, o) ->
            identity = o
            done()

      describe 'for an existing user', ->
        existingUser = undefined
        loggedInUser = undefined

        beforeEach (done) ->
          Factory "user",
            { identities: [identity] }
            (err, o) ->
              existingUser = o
  
              User.logIn identity, (err, o) ->
                loggedInUser = o
                done()
  
        it 'passes the user to the callback', ->
          expect(existingUser.id).toEqual(loggedInUser.id)

      describe 'for a non-existing user', ->

  describe '.avatarFor', ->
    describe 'given a Twitter handle', ->
      beforeEach ->
        @handle = '@handle'
        @avatar = User.avatarFor @handle

      it "returns a Twitter API url to the handle's avatar", ->
        expect(@avatar).toMatch /api.twitter.com/

    describe 'given a non-Twitter handle', ->
      beforeEach ->
        @handle = 'handle'
        @avatar = User.avatarFor @handle

      it 'returns a Gravatar url for the handle', ->
        expect(@avatar).toMatch /www.gravatar.com/
