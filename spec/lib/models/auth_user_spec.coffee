{ Factory, AuthUser } = require "../support/model_test_support"

describe 'User', ->
  beforeEach ->
    Factory.sync.createBundle()

  describe 'Social Profiles', ->

    it '.findByTwitterId returns a user with the given Twitter profile', ->
      twitterId = 'tweeter-1'
      authUser = AuthUser.sync.findByTwitterId twitterId
      expect(authUser.twitterProfile().providerId).toEqual twitterId

    it '.findByFacebookId returns a user with the given facebook profile', ->
      facebookId = 'facebooker-1'
      authUser = AuthUser.sync.findByFacebookId facebookId
      expect(authUser.facebookProfile().providerId).toEqual facebookId

    it '.findByGoogleId returns a user with the given google profile', ->
      googleId = 'googler-1'
      authUser = AuthUser.sync.findByGoogleId googleId
      expect(authUser.googleProfile().providerId).toEqual googleId

    it '.findByEmail returns a user with the given emailProfile', ->
      email = 'emailer-1'
      authUser = AuthUser.sync.findByEmail email
      expect(authUser.emailProfile().providerId).toEqual email

    it '.findByUsername returns a user with the given username profile', ->
      username = 'usernamer-1'
      authUser = AuthUser.sync.findByUsername username
      expect(authUser.usernameProfile().providerId).toEqual username
