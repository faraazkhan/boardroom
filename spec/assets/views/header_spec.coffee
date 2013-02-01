describe 'boardroom.views.Header', ->
  beforeEach ->
    setFixtures '''
      <div id="board-nav">
        <input id="name" />
        <button class="create" />
      </div>
'''
    @board = new boardroom.models.Board { name: 'foo' }
    @header = new boardroom.views.Header
      model: @board
    @$name = $('#name')

  describe 'change name', ->
    it 'updates the model', ->
      @$name.val 'bar'
      keyup = $.Event 'keyup'
      keyup.keyCode = 50
      @$name.trigger keyup
      expect(@board.get('name')).toEqual('bar')

  describe 'press enter', ->
    it 'blurs the name', ->
      @$name.focus()
      keyup = $.Event 'keyup'
      keyup.keyCode = 13
      @$name.trigger keyup
      expect(document.activeElement.tagName).not.toMatch /input/i

  describe 'board name changes', ->
    it 'updates the html', ->
      @board.set 'name', 'bar'
      expect(@$name.val()).toEqual 'bar'
