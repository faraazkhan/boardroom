facebook = require '../../../../../lib/services/authentication/providers/facebook'

describe 'Facebook', ->
  it 'exists', ->
    expect(facebook).toExist

  it 'has facebook as its name', ->
    expect(facebook.name).toEqual 'facebook'

  it '.identityFromOAuth', ->
    facebookId = 1111111
    username = 'a_facebook_user'
    displayName = 'Facebook User'
    profileImage = "https://graph.facebook.com/#{facebookId}/picture"
    profile = 
      id: facebookId
      provider: 'facebook'
      username: username
      displayName: displayName

    identity = facebook.identityFromOAuth 'token', 'secret', profile
    expect(identity.avatar).toEqual profileImage