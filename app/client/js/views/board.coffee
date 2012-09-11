class boardroom.views.Board extends Backbone.View
  el: '.board'

  initialize: (attributes) ->
    { @socket } = attributes
    @focusNextCreate = false
    @cardLocks = {}

    board = @model
    @boardroom = boardroomFactory(@socket, board)

    @socket.on 'move', @onMoveCard
    @socket.on 'add', @onCreateCard
    @socket.on 'delete', @onDeleteCard
    @socket.on 'text', @onText
    @socket.on 'joined', (user) =>
      board.users[user.user_id] = user
    @socket.on 'connect', ->
      @socket.emit 'join', user_id: board.user_id
    @socket.on 'title_changed', (title) ->
      $('#title').val title
    @socket.on 'color', @onColor
    @socket.on 'boardDeleted', ->
      alert 'This board has been deleted by its owner.'
      window.location = '/boards'
    @socket.on 'group', @boardroom.onGroup
    @socket.on 'createdOrUpdatedGroup', @boardroom.group.onCreatedOrUpdated
    @socket.on 'removedCard', (data) =>
      @boardroom.group.remove $("##{data.cardId}")

    setInterval ->
      currentTime = new Date().getTime()
      for own cardId, cardLock of @cardLocks
        timeout = if cardLock.move then 500 else 5000
        if currentTime - cardLock.updated > timeout
          $("##{cardId} .notice").fadeOut 100
          $("##{cardId} textarea").removeAttr 'disabled'
          delete @cardLocks[cardId]
    , 100

    @onCreateCard card for card in @model.get 'cards'

    $('.board').on 'click', '.stack-name', @changeStackName

    for own groupId, group of board.groups
      for cardId in group.cardIds
        $card = $ "##{cardId}"
        $card.data 'group-id', groupId
        $card.off 'mousedown'
        $card.followDrag @boardroom.dragOptions($card)

      @boardroom.group.onCreatedOrUpdated $.extend(group, { _id: groupId })

  changeStackName: (event) =>
    $stackElement = $ event.target
    offset = $stackElement.offset()
    offset.left -= 1

    $input = $('<input type="text" class="stack-name-edit">').val($stackElement.text())
    $input.appendTo($stackElement.parent()).offset(offset).focus()
    $stackElement.remove()

    $input.on 'blur change', =>
      $stackElement.text($input.val())
      $stackElement.appendTo($input.parent())
      $input.remove()
      targetGroupId = $stackElement.attr('id').split('-')[0]
      @socket.emit 'updateGroup', {boardName: board.name, _id: targetGroupId, name: $input.val()}

  adjustTextarea: ($textarea) ->
    $textarea.css 'height', 'auto'
    if $textarea.innerHeight() < $textarea[0].scrollHeight
      $textarea.css 'height', $textarea[0].textarea.scrollHeight + 14
    @analyzeCardContent $textarea

  analyzeCardContent: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  onMoveCard: (move) =>
    $card = $("##{move._id}")
      .css
        left: move.x
        top: move.y
    unless $('.notice', $card).is ':visible'
      @notice move._id, move.moved_by, move.moved_by
      @cardLocks[move._id] =
        user_id: move.moved_by,
        updated: new Date().getTime(),
        move: true
    @boardroom.moveToTop $card

  onDeleteCard: (card) ->
    $("##{card._id}").remove()

  notice: (cardId, userId, message) =>
    $("##{cardId} .notice")
      .html("<img src='#{boardroom.models.User.avatar userId}'/>
             <span>#{_.escape message}</span>")
      .show()

  addAuthor: (cardId, author) =>
    if $("##{cardId} .authors img[title='#{author}']").length is 0
      $("##{cardId} .authors")
        .append("<img src='#{boardroom.models.User.avatar author}' title='#{_.escape author}'/>")

  onCreateCard: (data) =>
    card = new boardroom.models.Card data
    card.set 'board', @model
    cardView = new boardroom.views.Card
      model: card
      boardroom: @boardroom
      socket: @socket
    $('.board').append cardView.render().el

    if @focusNextCreate
      $('textarea', cardView.$el).focus()
      @focusNextCreate = false

    @boardroom.moveToTop cardView.$el

  onColor: (data) ->
    $card = $("##{data._id}")
    $card.removeClassMatching /color-\d+/g
    $card.addClass "color-#{data.colorIndex}"

  onText: (data) =>
    $textarea = $("##{data._id} textarea")
    $textarea.val(data.text).attr 'disabled', 'disabled'
    if ! @cardLocks[data._id] || @cardLocks[data._id].user_id != data.author
      @notice data._id, data.author, "#{data.author} is typing..."
    $("##{data._id} .notice").show()
    @cardLocks[data._id] =
      user_id: data.author
      updated: new Date().getTime()
    @addAuthor data._id, data.author
    @adjustTextarea $textarea
    @boardroom.moveToTop "##{data._id}"
