describe '$', ->
  describe '#removeClassMatching', ->
    beforeEach ->
      setFixtures '''
        <ul id="colors">
          <li class="color color-0"></li>
          <li class="color color-1"></li>
          <li class="color color-2"></li>
          <li class="color color-3"></li>
          <li class="color color-4"></li>
        </ul>
      '''
      $('#colors li').removeClassMatching /color-\d/

    it 'removes classes matching the given regular expression', ->
      $('#colors li').each (index, li) ->
        expect(li).not.toHaveClass "color-#{index}"
