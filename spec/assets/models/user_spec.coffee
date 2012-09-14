describe 'boardroom.models.User', ->
  describe '.avatar', ->
    beforeEach ->
      @handle = '@handle-1 handle-2'

      @avatar = boardroom.models.User.avatar @handle

    it 'returns the avatar url', ->
      expect(@avatar).toEqual "/user/avatar/#{encodeURIComponent @handle}"
