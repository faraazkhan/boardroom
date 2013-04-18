twitter = require '../../../../../lib/services/authentication/providers/twitter'

describe 'Twitter', ->
  it 'exists', ->
    expect(twitter).toExist

  it 'has twitter as its name', ->
    expect(twitter.name).toEqual 'twitter'

  it '.identityFromOAuth', ->
    twitterId = 1111111
    username = 'a_twitter_user'
    displayName = 'Twitter User'
    avatar = 'https://si0.twimg.com/profile_images/2989131844/bbb85fc25c5f3b2712bba2ffd38cbe4a_normal.jpeg'
    profile = 
      provider: 'twitter'
      providerId: twitterId
      username: username
      displayName: displayName
      photos: [ { value: avatar } ]
      _json:
         id: twitterId
         id_str: '#{twitterId}'
         name: displayName
         screen_name: username
         location: 'Santa Monica'
         profile_image_url_https: avatar

    identity = twitter.identityFromOAuth 'token', 'secret', profile
    expect(identity.avatar).toEqual avatar
