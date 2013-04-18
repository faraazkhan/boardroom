google = require '../../../../../lib/services/authentication/providers/google'

describe 'Google', ->
  it 'exists', ->
    expect(google).toExist

  it 'has google as its name', ->
    expect(google.name).toEqual 'google'

  it '.identityFromOAuth', ->
    googleId = 1111111    
    username = 'a_google_user'
    displayName = 'Google User'
    profile = 
      providerId: googleId
      displayName: displayName
      emails: [ { value: "#{username}@carbonfive.com" } ]
      name: { familyName: 'User', givenName: 'Google' }

    identity = google.identityFromOAuth 'google.com/identifier', profile
    expect(identity.avatar).toExist
