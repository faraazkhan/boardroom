# { Board, Factory, url, async, describeController, superagent } =
#   require '../support/controller_test_support'

# describeController 'SessionsController', (session) ->
#   describe '#new', ->

#     it 'renders the login page', (done) ->
#       session.request()
#         .get('/login')
#         .end (req, res) ->
#           expect(res.ok).toBeTruthy()
#           done()

#   describe '#create', ->
#     describe 'given the user has existing boards', ->
#       boards = undefined
#       users = undefined

#       beforeEach (done) ->
#         Factory.createBundle (error, bundle) ->
#           { boards, users } = bundle
#           done()

#       it 'redirects to the home page', (done) ->
#         session.request()
#           .post('/login')
#           .send({user_id: users.boardCreator1.id})
#           .end (request, response) ->
#             expect(response.redirect).toBeTruthy()
#             redirect = url.parse response.headers.location
#             expect(redirect.path).toEqual '/'
#             done()

#     describe 'given the user has no boards', ->
#       userId = undefined

#       beforeEach (done)->
#         Factory.create 'user', (error, user) ->
#           userId = user.id
#           done()

#       it 'creates a default board and redirects to its page', (done) ->
#         session.request()
#           .post('/login')
#           .send({user_id: userId})
#           .end (request, response) ->
#             expect(response.redirect).toBeTruthy()

#             Board.count (err, count) ->
#               expect(count).toEqual 1

#               Board.findOne { _creator: userId}, (err, board) ->
#                 redirect = url.parse response.headers.location
#                 expect(redirect.path).toEqual "/boards/#{board.id}"
#                 expect(board.name).toEqual "#{userId}'s board"
#                 done()

#     describe 'given the user is trying to go to an existing board', ->
#       agent = undefined
#       userId = undefined

#       beforeEach (done)->
#         Factory.create 'user', (error, user) ->
#           userId = user.id
#           agent = superagent.agent()
#           done()

#       it 'brings the user to that board', (done) ->
#         async.series [
#           (done) ->
#             session.request()
#               .get('/boards/123')
#               .end (request, response) ->
#                 agent.saveCookies response
#                 done()
#           , (done) ->
#             req = session.request()
#               .post('/login')
#             agent.attachCookies req
#             req
#               .send({user_id: userId})
#               .end (request, response) ->
#                 expect(response.redirect).toBeTruthy()
#                 redirect = url.parse response.headers.location
#                 expect(redirect.path).toEqual '/boards/123'
#                 done()
#           ], done

#   describe '#destroy', ->
#     beforeEach ->
#       session.login()

#     it 'logs out', (done) ->
#       session.request()
#         .get('/logout')
#         .end (request, response) ->
#           expect(response.redirect).toBeTruthy()
#           redirect = url.parse response.headers.location
#           expect(redirect.path).toEqual '/'
#           done()
