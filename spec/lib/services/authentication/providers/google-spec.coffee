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
    emailAddress = "#{username}@carbonfive.com"
    profile =
      id: googleId
      displayName: displayName
      _json:
        email: emailAddress

    identity = google.identityFromOAuth 'accessToken', 'refreshToken', profile
    expect(identity.email).toEqual emailAddress
