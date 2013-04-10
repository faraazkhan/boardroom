{ User, Factory } = require "../support/model_test_support"

describe 'User', ->
  it "exists", ->
    expect(User).toBeDefined()

  describe "logging in", ->
    describe 'given an authenticated profile', ->
      identity = undefined

      beforeEach ->
        Factory 'identity', (err, o) ->
          identity = o

      describe 'for an existing user', ->
        existingUser = undefined
        loggedInUser = undefined

        beforeEach (done) ->
          Factory "user", (err, o) ->
            existingUser = o

            User.logIn identity, (err, o) ->
              loggedInUser = o
              done()

        it 'passes the user to the callback', ->
          expect(existingUser._id).toEqual(loggedInUser._id)

        it "updates the last login stats of the user", ->
          existingStats = existingUser.loginStats
          loggedInStats = loggedInUser.loginStats

          expect(loggedInStats.loginCount).toEqual(existingStats.loginCount + 1)
          expect(loggedInStats.lastLoginTime).toBeGreaterThan(existingStats.lastLoginTime)
          expect(loggedInStats.lastLoginSource).toEqual(identity.source)

      #describe 'for a non-existing user', ->

  describe '.avatar_for', ->
    describe 'given a Twitter handle', ->
      beforeEach ->
        @handle = '@handle'
        @avatar = User.avatar_for @handle

      it "returns a Twitter API url to the handle's avatar", ->
        expect(@avatar).toMatch /api.twitter.com/

    describe 'given a non-Twitter handle', ->
      beforeEach ->
        @handle = 'handle'
        @avatar = User.avatar_for @handle

      it 'returns a Gravatar url for the handle', ->
        expect(@avatar).toMatch /www.gravatar.com/
