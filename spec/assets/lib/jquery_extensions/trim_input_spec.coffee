describe '$', ->
  describe '#trimInput', ->
    describe 'by default', ->
      beforeEach ->
        setStyleFixtures '''
          input { width: 500px; }
        '''
        setFixtures '''
          <input id='trimmable' type=text/>
        '''
        $('#trimmable').css(
          padding: 0
          border: 'none'
        ).trimInput(20, 500) # this should all work without passing these params (but it doesn't)

      it 'sets a minimum width when there is no text', ->
        expect($('#trimmable').css('width')).toEqual '20px'

      it 'sets the text to the original width when focused', ->
        $('#trimmable').focus()
        expect($('#trimmable').css('width')).toEqual '500px'

      it 'sets the input width to match the amount of text', ->
        $('#trimmable')
          .focus()
          .val('She sell sea shells down by the shore')
          .blur()

        newWidth = parseInt($('#trimmable').css('width'))
        expect(newWidth).toBeGreaterThan 20

      it 'sets width to the maximum width when there is more text', ->
        $('#trimmable')
          .focus()
          .val('''
            All work and no play makes Jack a dull boy
            All work and no play makes Jack a dull boy
            All work and no play makes Jack a dull boy
          ''')
          .blur()
        expect($('#trimmable').css('width')).toEqual '500px'
