{ User, Factory, Identity } = require "../support/model_test_support"

describe 'User', ->
  it "exists", ->
    expect(User).toBeDefined()

  describe "logging in", ->
    describe 'given an authenticated identity', ->
      source          = undefined
      sourceId        = undefined
      username        = undefined
      email           = undefined
      displayName     = undefined
      passedIdentity  = undefined

      beforeEach (done) ->
        source          = 'identitySource'
        sourceId        = '123'
        username        = 'foo'
        email           = 'foo@here.com'
        displayName     = username
        passedIdentity  = undefined
        Factory.build 'identity',
          { source, sourceId, username, email, displayName },
          (error, o) ->
            passedIdentity = o
            done()

      describe 'for a legacy user who had a previous (non-oauth) account', ->
        legacyUser = undefined
        loggedInUser = undefined

        describe 'with a twitter login', ->
          beforeEach (done) ->
            source = 'twitter'
            username = 'twitter_user'
            displayName = username
            email = undefined
            legacyId = "@#{username}"
            Factory.build 'identity',
              { source:'boardroom-legacy', sourceId:legacyId, username: legacyId, displayName: legacyId }
              (err, existingIdentity) ->
                Factory "user",
                  { identities: [existingIdentity] }
                  (err, o) ->
                    legacyUser = o
                    Factory.build 'identity',
                      { source, sourceId, username },
                      (error, o) ->
                        passedIdentity = o
                        User.logIn passedIdentity, (err, o) ->
                          loggedInUser = o
                          done()

          it 'captures the old account', ->
            expect(legacyUser.id).toEqual(loggedInUser.id)

        describe 'with an email login', ->
          beforeEach (done) ->
            source = 'google'
            username = 'email.user'
            displayName = username
            email = "#{username}@gmail.com"
            legacyId = email
            Factory.build 'identity',
              { source:'boardroom-legacy', sourceId:legacyId, username:legacyId, displayName:legacyId }
              (err, existingIdentity) ->
                Factory "user",
                  { identities: [existingIdentity] }
                  (err, o) ->
                    legacyUser = o
                    Factory.build 'identity',
                      { source, sourceId, username, email, displayName },
                      (error, o) ->
                        passedIdentity = o
                        User.logIn passedIdentity, (err, o) ->
                          loggedInUser = o
                          done()

          it 'captures the old account', ->
            expect(legacyUser.id).toEqual(loggedInUser.id)

      describe 'for an existing user with a matching identity', ->
        existingUser = undefined
        loggedInUser = undefined

        beforeEach (done) ->
          Factory.build 'identity',
            { source: source, sourceId: sourceId, displayName: 'bar' }
            (err, existingIdentity) ->
              Factory "user",
                { identities: [existingIdentity] }
                (err, o) ->
                  existingUser = o

                  User.logIn passedIdentity, (err, o) ->
                    loggedInUser = o
                    done()

        it 'passes the user to the callback', ->
          expect(existingUser.id).toEqual(loggedInUser.id)

        it 'updates the stored identity with the most recent information', ->
          expect(loggedInUser.identities[0].displayName).toEqual('foo')

      describe 'for a non-existing user', ->
        newUser = undefined

        beforeEach (done) ->
          User.logIn passedIdentity, (err, o) ->
            newUser = o
            done()

        it 'creates a new user', ->
          expect(newUser).toBeDefined()

        it 'associates the identity to the new user', ->
          expect(newUser.identities.length).toEqual 1
          expect(newUser.identities[0].equals(passedIdentity)).toBeTruthy()

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
