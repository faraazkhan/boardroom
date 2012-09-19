describe 'boardroom.views.BoardItem', ->
  describe 'socket events', ->
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
