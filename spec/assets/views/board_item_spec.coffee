describe 'boardroom.views.BoardItem', ->
  describe 'DOM events', ->
    describe 'clicking the delete button', ->
      beforeEach ->
        setFixtures """
          <div class='boards'>
            <ul>
              <li id='1'>
                <h4 class='title'></h4>
                <div class="actions">
                  <form action="/boards/1" method="post">
                    <input type="submit" value="Delete" />
                  </form>
                </div>
              </li>
            </ul>
          </div>
        """
        @confirmStub = sinon.stub window, 'confirm', ->
          false
        @boardItemView = new boardroom.views.BoardItem
          el: $('li')
          model: @model

        @boardItemView
          .$('form')
          .submit()

      afterEach ->
        window.confirm.restore()

      it 'requires you to confirm the deletion', ->
        expect(window.confirm.called).toBeTruthy()
