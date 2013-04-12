{ Card, Group, Factory, async } = require "../support/model_test_support"

describe 'Group', ->
  it "exists", ->
    expect(Group).toBeDefined()

  describe ".collaboratedBy", ->

    describe "given a user", ->
      user = undefined
      groupA = undefined
      groupC = undefined

      beforeEach (done) ->
        async.parallel {
          user: async.apply Factory.create, 'user'
          otherUser: async.apply Factory.create, 'user'
          groupA: async.apply Factory.create, 'group', name: 'A'
          groupB: async.apply Factory.create, 'group', name: 'B'
          groupC: async.apply Factory.create, 'group', name: 'C'
        }, (err, results) ->
          { user, otherUser, groupA, groupB, groupC } = results

          async.parallel [
            async.apply Factory.create, "card", { groupId: groupA.id, _authors: [user] }
            async.apply Factory.create, "card", { groupId: groupA.id, _authors: [otherUser] }
            async.apply Factory.create, "card", { groupId: groupA.id, _authors: [user] }
            async.apply Factory.create, "card", { groupId: groupB.id, _authors: [otherUser] }
            async.apply Factory.create, "card", { groupId: groupC.id, _authors: [user, otherUser] }
          ], done

      it "only returns groups that the user has collaborated on", (done) ->
        Group.collaboratedBy user, (err, groups) ->
          expect(err).toBeNull()
          expect(groups.length).toEqual(2)
          expect(groups[0].name).toEqual groupA.name
          expect(groups[1].name).toEqual groupC.name
          done()
