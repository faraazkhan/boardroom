describe 'boardroom.views.BoardList', ->
  describe '#render', ->
    beforeEach ->
      setFixtures '''
        <div id="boards">
          <ul>
            <li id="1"></li>
            <li id="2"></li>
            <li id="3"></li>
          </ul>
        </div>
      '''
      @boardList = new boardroom.views.BoardList

      @boardList.render()

    it 'creates a view for each board', ->
      boardItems = @boardList.boardItems
      expect(boardItems.length).toEqual 3
