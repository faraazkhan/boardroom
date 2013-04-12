{ Factory, Card } = require "../support/model_test_support"

describe 'card.Card', ->
  describe '.findByGroupId', ->
    beforeEach (next) =>
      Factory 'group', (err, @group) =>
        Factory 'card', groupId: @group.id, ->
          next()

    it 'finds all cards for the given group', (done) =>
      Card.findByGroupId @group.id, (err, cards) ->
        expect(cards.length).toEqual 1
        done()

  describe '#updateAttributes', ->
    describe 'by default', ->
      beforeEach (done) =>
        Factory 'card', (err, card) =>
          @card = card
          Factory 'user', (err, user) =>
            @user = user
            done()

      it 'updates its attributes', (done) =>
        numAuthors = @card.authors.length
        numPlusAuthors = @card.plusAuthors.length
        attributes =
          text: "#{@card.text}-updated"
          colorIndex: @card.colorIndex + 1
          deleted: ! @card.deleted
          authors: [ @card.authors... ,  'author1' ]
          _authors: [ @user ]
          plusAuthors: [ @card.plusAuthors... , 'plusAuthor1']
          _plusAuthors: [ @user ]

        @card.updateAttributes attributes, (err) =>
          Card.findById @card.id, (err, card) ->
            expect(card.text).toEqual attributes.text
            expect(card.colorIndex).toEqual attributes.colorIndex
            expect(card.authors.length).toEqual numAuthors+1
            expect(card.plusAuthors.length).toEqual numPlusAuthors+1
            expect(card._authors.length).toEqual 1
            expect(card._plusAuthors.length).toEqual 1
            done()
