{ Factory, Board, Group, Card, async, _ } = require "../support/model_test_support"

createBundle = (boardName, user, done) ->
  Factory.create "board", { name: boardName }, (err, board) ->
    Factory.create "group", { boardId: board.id }, (err, group) ->
      Factory.create "card", {
        groupId: group.id,
        creator: user
        authors: [user]
      }, (err, card) ->
        done null, {
          board: board
          group: group
          card: card
        }

describe 'board.Board', ->
  describe '.createdBy', ->
    describe 'given a user', ->
      user = undefined

      beforeEach (done) ->
        async.parallel {
          user: async.apply Factory.create, 'user'
          otherUser: async.apply Factory.create, 'user'
        }, (err, results) ->
          { user, otherUser } = results

          async.parallel [
            async.apply Factory.create, 'board', { _creator: user, name: 'board1' }
            async.apply Factory.create, 'board', { _creator: otherUser, name: 'board2' }
            async.apply Factory.create, 'board', { _creator: otherUser, name: 'board3' }
            async.apply Factory.create, 'board', { _creator: user, name: 'board4' }
            async.apply Factory.create, 'board', { _creator: user, name: 'board5' }
          ], done

      it 'only returns boards created by that user', (done) ->
        Board.createdBy user, (err, boards) ->
          expect(boards.length).toEqual 3
          expect(boards[0].name).toEqual 'board1'
          done()

  describe '.collaboratedBy', ->
    describe 'given a user and some boards', ->
      users = undefined
      boardA = undefined
      boardB = undefined

      beforeEach (done) ->
        async.parallel [
          async.apply Factory.create, 'user'
          async.apply Factory.create, 'user'
        ], (err, results) ->
          users = results
          async.parallel [
            async.apply createBundle, "board1", users[0]
            async.apply createBundle, "board2", users[0]
          ], (err, bundles) ->
            boardA = bundles[0].board
            boardB = bundles[1].board

            bundles[1].card._authors.push users[1]
            bundles[1].card.save done

      it 'only returns boards that the user has collaborated on', (done) ->
        Board.collaboratedBy users[1], (err, boards) ->
          expect(err).toBeNull()
          expect(boards.length).toEqual(1)
          expect(boards[0].name).toEqual boardB.name
          done()

  describe '#lastUpdated', ->
    beforeEach (done) =>

      createBoard = (done) =>
        Factory "board", (err, board) =>
          @board = board
          done()

      createGroup = (done) =>
        Factory "group", boardId: @board.id, (err, group) =>
          @group = group
          done()

      createCard = (done) =>
        Factory "card", groupId: @group.id, (err, card) =>
          @card = card
          done()

      async.series [ createBoard, createGroup, createCard ], done

    it 'returns last updated of cards', (done) =>
      @card.save (err) =>
        Board.findById @board.id, (err, board) =>
          expect(board.lastUpdated().getTime()).toEqual @card.updated.getTime()
          done()

    it 'returns last updated of board', (done) =>
      @board.save (err) =>
        Board.findById @board.id, (err, board) =>
          expect(board.lastUpdated().getTime()).toEqual @board.updated.getTime()
          done()

  describe '#remove', ->
    beforeEach (done) =>
      createBoard = (done) =>
        Factory "board", (err, board) =>
          @board = board
          done()

      createGroup = (done) =>
        Factory "group", boardId: @board.id, (err, group) =>
          @group = group
          done()

      createCard = (done) =>
        Factory "card", groupId: @group.id, (err, card) =>
          @card = card
          done()

      async.series [ createBoard, createGroup, createCard, createCard ], done

    it 'removes the board', (done) =>
      @board.remove (err) ->
        count = Board.count {}, (err, count) ->
          expect(count).toEqual 0
          done()

    it "removes the board's groups", (done) =>
      @board.remove (err) ->
        count = Group.count {}, (err, count) ->
          expect(count).toEqual 0
          done()

    it "removes the board's cards", (done) =>
      @board.remove (err) ->
        count = Card.count {}, (err, count) ->
          expect(count).toEqual 0
          done()
