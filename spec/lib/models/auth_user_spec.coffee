{ Factory, AuthUser } = require "../support/model_test_support"

describe 'User', ->
  beforeEach ->
    Factory.sync.createBundle()

  describe 'Social Profiles', ->

    it '.findByTwitterId returns a user with the given Twitter profile', ->
      twitterId = 'tweeter-1'
      user = AuthUser.sync.findByTwitterId twitterId
      expect(user.twitterProfile().providerId).toEqual twitterId

    it '.findByFacebookId returns a user with the given facebook profile', ->
      facebookId = 'facebooker-1'
      user = AuthUser.sync.findByFacebookId facebookId
      expect(user.facebookProfile().providerId).toEqual facebookId

    it '.findByGoogleId returns a user with the given google profile', ->
      googleId = 'googler-1'
      user = AuthUser.sync.findByGoogleId googleId
      expect(user.googleProfile().providerId).toEqual googleId

    it '.findByEmail returns a user with the given email profile', ->
      email = 'emailer-1@c5.com'
      user = AuthUser.sync.findByEmail email
      expect(user.emailProfile().providerId).toEqual email

  describe '1st Sign In', ->
    now = new Date
    it '.signIn with twitter', ->
      profile = 
        providerId: 'tweeter-non-existent'
        provider: 'twitter'
        info: { now }
      user = AuthUser.sync.findByTwitterId profile.providerId
      expect(user).toEqual null

      user = AuthUser.sync.signIn profile  
      expect(user.twitterProfile().providerId).toEqual profile.providerId

      user = AuthUser.sync.findByTwitterId profile.providerId
      expect(user.twitterProfile().info.now).toEqual now

    it '.signin with facebook', ->
      profile = 
        providerId: 'facebook-non-existent'
        provider: 'facebook'
        info: { now }
      user = AuthUser.sync.findByFacebookId profile.providerId
      expect(user).toEqual null

      user = AuthUser.sync.signIn profile  
      expect(user.facebookProfile().providerId).toEqual profile.providerId

      user = AuthUser.sync.findByFacebookId profile.providerId
      expect(user.facebookProfile().info.now).toEqual now

    it '.signin with google', ->
      profile = 
        providerId: 'google-non-existent'
        provider: 'google'
        info: { now }
      user = AuthUser.sync.findByGoogleId profile.providerId
      expect(user).toEqual null

      user = AuthUser.sync.signIn profile  
      expect(user.googleProfile().providerId).toEqual profile.providerId

      user = AuthUser.sync.findByGoogleId profile.providerId
      expect(user.googleProfile().info.now).toEqual now

    it '.signin with email', ->
      profile = 
        providerId: 'email-non-existent'
        provider: 'email'
        info: { now }
      user = AuthUser.sync.findByEmail profile.providerId
      expect(user).toEqual null

      user = AuthUser.sync.signIn profile  
      expect(user.emailProfile().providerId).toEqual profile.providerId

      user = AuthUser.sync.findByEmail profile.providerId
      expect(user.emailProfile().info.now).toEqual now

  describe 'returning', ->
    it '.signIn with twitter', ->
      profile = 
        providerId: 'tweeter-1'
        provider: 'twitter'
      user = AuthUser.sync.signIn profile  
      expect(user.twitterProfile().providerId).toEqual profile.providerId

    it '.signin with facebook', ->
      profile = 
        providerId: 'facebooker-1'
        provider: 'facebook'
      user = AuthUser.sync.signIn profile  
      expect(user.facebookProfile().providerId).toEqual profile.providerId

    it '.signin with google', ->
      profile = 
        providerId: 'googler-1'
        provider: 'google'
      user = AuthUser.sync.signIn profile  
      expect(user.googleProfile().providerId).toEqual profile.providerId

    it '.signin with email', ->
      profile = 
        providerId: 'emailer-1@c5.com'
        provider: 'email'
      user = AuthUser.sync.signIn profile  
      expect(user.emailProfile().providerId).toEqual profile.providerId
