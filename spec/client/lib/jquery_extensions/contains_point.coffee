  # mock offset(), since there's no CSS renderer etc.
describe '$', ->
  describe '#containsPoint', ->
    beforeEach ->
      setFixtures '''
        <div id="board" style="position:absolute; width: 100px; height: 200px;">
      '''

      @$div = $ '#board'
      @$div.offset = ->
        left: 50
        top: 150

    it 'returns true when the point in inside', ->
      expect(@$div.containsPoint(125, 200)).toBeTruthy()

    it 'returns false when the point is left of the element', ->
      expect(@$div.containsPoint(49, 150)).toBeFalsy()

    it 'returns false when the point is above of the element', ->
      expect(@$div.containsPoint(50, 149)).toBeFalsy()
