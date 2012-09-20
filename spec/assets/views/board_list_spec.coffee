describe 'boardroom.views.BoardList', ->
  describe 'DOM events', ->
    describe 'clicking the delete button', ->
      beforeEach ->
        setFixtures """
          <div id='boards'>
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
        @boardListView = new boardroom.views.BoardList

        @boardListView
          .$('form')
          .submit()

      afterEach ->
        window.confirm.restore()

      it 'requires you to confirm the deletion', ->
        expect(window.confirm.called).toBeTruthy()
