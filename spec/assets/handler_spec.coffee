describe 'boardroom.Handler', ->
  beforeEach ->
    @socket = new io.Socket()
    @board = new boardroom.models.Board {}
    @user = new boardroom.models.User { user_id: 1 }

  describe '#constructor', ->
    beforeEach ->
      @handler = handler_for @socket, @board, @user

    it 'emits a join message', ->
      expect(@handler.send).toHaveBeenCalledWith('join', @user.toJSON())

  describe '*join', ->
    beforeEach ->
      @handler = handler_for @socket, @board, @user
      @newUser = { user_id: 2 }
      @socket.emit 'join', @newUser

    it 'adds user to board', ->
      users = @board.get 'users'
      expect(users[@newUser.user_id]).toEqual @newUser

handler_for = (socket, board, user) ->
  handler = new boardroom.Handler board, user
  spyOn(handler, 'createSocket').andReturn(socket)
  spyOn(handler, 'send')
  handler.initialize()
  handler
