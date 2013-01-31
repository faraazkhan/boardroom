describe 'boardroom.Handler', ->
  beforeEach ->
    @socket = new io.Socket()
    @board = new boardroom.models.Board {}
    @user = new boardroom.models.User { user_id: 1 }
    @handler = handler_for @socket, @board, @user

  describe '*connect', ->
    it 'emits a join message', ->
      @socket.emit 'connect'
      expect(@handler.send).toHaveBeenCalledWith('join', @user.toJSON())

  describe '*disconnect', ->
    it 'displays a "Disconnected" message', ->
      @socket.emit 'disconnect'
      expect(@board.get 'status').toEqual 'Disconnected'

  describe '*reconnecting', ->
    it 'displays a "Reconnecting..." message', ->
      @socket.emit 'reconnecting'
      expect(@board.get 'status').toEqual 'Reconnecting...'

  describe '*reconnect', ->
    it 'clears the status message', ->
      @socket.emit 'reconnect'
      expect(@board.get 'status').toBeNull()

  describe '*join', ->
    beforeEach ->
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
