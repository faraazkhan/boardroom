{ Factory, Card } = require "../support/model_test_support"

describe 'Card', ->
  describe '.findByGroupId', ->
    groupId = undefined

    beforeEach (next) ->
      Factory.create 'user', (err, user)->
        Factory 'group', (err, group) ->
          creator = user.id
          groupId = group.id
          Factory 'card', { groupId, creator }, (error, card) ->
            next()

    it 'finds all cards for the given group', (done) =>
      Card.findByGroupId groupId, (err, cards) ->
        expect(cards.length).toEqual 1
        done()

  describe '#updateAttributes', ->
    describe 'by default', ->
      beforeEach (done) =>
        Factory 'card', (err, card) =>
          @card = card
          done()

      it 'updates its attributes', (done) =>
        Factory.create 'user', (err, author)=>
          Factory.create 'user', (err, plusAuthor)=>
            numAuthors = @card.authors.length
            numPlusAuthors = @card.plusAuthors.length
            attributes =
              text: "#{@card.text}-updated"
              colorIndex: @card.colorIndex + 1
              deleted: ! @card.deleted
              authors: [ @card.authors... ,  author.id ]
              plusAuthors: [ @card.plusAuthors... , plusAuthor.id ]

            @card.updateAttributes attributes, (err) =>
              Card.findById @card.id, (err, card) ->
                expect(card.text).toEqual attributes.text
                expect(card.colorIndex).toEqual attributes.colorIndex
                expect(card.authors.length).toEqual numAuthors+1
                expect(card.plusAuthors.length).toEqual numPlusAuthors+1
                done()
