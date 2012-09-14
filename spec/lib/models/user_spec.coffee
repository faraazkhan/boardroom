User = require "#{__dirname}/../../../lib/models/user"

describe 'User', ->
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
