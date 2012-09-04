describe 'board', ->
  describe '#analyzeCardContent', ->
    beforeEach ->
      setFixtures '''
        <div class="card i-wish i-like">
          <textarea id="card-content"/>
        </div>
      '''

    describe 'by default', ->
      beforeEach ->
        analyzeCardContent '#card-content'

      it 'removes existing like/wish classes' , ->
        card = $ '.card'
        expect(card).not.toHaveClass 'i-wish'
        expect(card).not.toHaveClass 'i-like'
