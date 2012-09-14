describe 'boardroom.models.Board', ->
  describe '#addUser', ->
    beforeEach ->
      @users = {}
      @board = new boardroom.models.Board
        users: @users
      @user =
        user_id: '1'

      @board.addUser @user

    it 'adds the user to its users', ->
      expect(@board.get('users')[@user.user_id]).toEqual @user

