describe 'boardroom.views.BoardItem', ->
  describe 'socket events', ->
    describe 'when the board changes', ->
      beforeEach ->
        @id = '1'
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='#{@id}'>
                <h4 class='title'></h4>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @data =
          _id: @id
          title: 'title'

        @socket.emit 'board_changed', @data

      it 'updates its title', ->
        expect(@boardItemView.$('.title')).toHaveText @data.title

    describe 'when a card is added to the board', ->
      beforeEach ->
        @id = '1'
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='#{@id}'>
                <h4 class='title'></h4>
                <span class="count">0</span>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @data =
          _id: @id

        @socket.emit 'card_added', @data

      it 'increases its total card count', ->
        expect(@boardItemView.$('.count')).toHaveText 1

    describe 'when a card is removed from the board', ->
      beforeEach ->
        @id = '1'
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='#{@id}'>
                <h4 class='title'></h4>
                <span class="count">1</span>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @data =
          _id: @id

        @socket.emit 'card_deleted', @data

      it 'decreases its total card count', ->
        expect(@boardItemView.$('.count')).toHaveText 0

    describe 'when a user does something to the board', ->
      beforeEach ->
        @id = '1'
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='#{@id}'>
                <h4 class='title'></h4>
                <span class="count">1</span>
                <div class="activity"></div>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @data =
          _id: @id
        @userId = 1
        @activity = 'activity'

        @socket.emit 'user_activity', @data, @userId, @activity

      it 'displays the user that did something to the board', ->
        $avatar = @boardItemView.$ '.activity img'
        expect($avatar).toHaveAttr 'title', 'activity'
        expect($avatar).toHaveAttr 'src', "/user/avatar/#{@userId}"

    describe 'when the board is deleted', ->
      beforeEach ->
        @id = '1'
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='#{@id}'>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @data =
          id: @id

        @socket.emit 'delete', @data

      it 'removes itself', ->
        expect(@boardItemView.$('p')).toHaveText 'This board has been deleted.'

  describe 'DOM events', ->
    describe 'clicking the delete button', ->
      beforeEach ->
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='1'>
                <h4 class='title'></h4>
                <div class="delete">
                  <div class="message">
                    Delete
                  </div>
                </div>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket

        @boardItemView
          .$('.delete')
          .click()

      it 'requires you to confirm the deletion', ->
        expect(@boardItemView.$('.delete')).toHaveClass 'confirm'

    describe 'confirming a deletion', ->
      beforeEach ->
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='1'>
                <h4 class='title'></h4>
                <div class="delete confirm">
                  <div class="message">
                    Delete
                  </div>
                </div>
              </li>
            </ul>
          </div>
        """
        @socket = new io.Socket
        @boardItemView = new boardroom.views.BoardItem
          el: $('.boards li')
          socket: @socket
        @delete = sinon.spy()
        @socket.on 'delete', @delete

        @boardItemView
          .$('.delete')
          .click()

      it 'emits a "delete" socket event', ->
        expect(@delete.called).toBeTruthy()
