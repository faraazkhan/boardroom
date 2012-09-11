#= require './boardroom'

class boardroom.views.Board extends Backbone.View
  el: '.board'

  initialize: (@header) ->
    @boardroom = null
    @focusNextCreate = false
    @cardLocks = {}
    $.getJSON "#{document.location.pathname}/info",
      (board) =>
        boardroom.board = board
        @begin()

  adjustTextarea: (textarea) ->
    $(textarea).css 'height', 'auto'
    if $(textarea).innerHeight() < textarea.scrollHeight
      $(textarea).css 'height', textarea.scrollHeight + 14
    analyzeCardContent textarea

  analyzeCardContent: (textarea) ->
    $card = $(textarea).parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $(textarea).val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  cleanHTML: (str = '') ->
    str.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g,'&amp;')

  avatar: (user) ->
    "/user/avatar/#{encodeURIComponent user}"

  begin: ->
    board = boardroom.board
    socketURL = "http://#{document.location.host}/boardNamespace/#{board.name}"
    socket = io.connect(socketURL)
    @boardroom = boardroomFactory(socket, board)

    socket.on 'move', @onMoveCard
    socket.on 'add', @onCreateCard
    socket.on 'delete', @onDeleteCard
    socket.on 'text', @onText
    socket.on 'joined', (user) =>
      board.users[user.user_id] = user
    socket.on 'connect', ->
      socket.emit 'join', user_id: board.user_id
    socket.on 'title_changed', (title) ->
      $('#title').val title
    socket.on 'color', @onColor
    socket.on 'boardDeleted', ->
      alert 'This board has been deleted by its owner.'
      window.location = '/boards'
    socket.on 'group', boardroom.onGroup
    socket.on 'createdOrUpdatedGroup', boardroom.group.onCreatedOrUpdated
    socket.on 'removedCard', (data) ->
      boardroom.group.remove $("##{data.cardId}")

    setInterval ->
      currentTime = new Date().getTime()
      for own cardId, cardLock of cardLocks
        timeout = if cardLock.move then 500 else 5000
        if currentTime - cardLock.updated > timeout
          $("##{cardId} .notice").fadeOut 100
          $("##{cardId} textarea").removeAttr 'disabled'
          delete cardLocks[cardId]
    , 100

    @onCreateCard card for card in board.cards

    for own groupId, group of board.groups
      for cardId in group.cardIds
        $card = $('#' + cardId)
        $card.data 'group-id', groupId
        $card.off 'mousedown'
        $card.followDrag boardroom.dragOptions($card)
      boardroom.group.onCreatedOrUpdated($.extend(group,{_id: groupId}))

      document.onselectstart = (e) ->
        $(e.target).is('input[type=text], textarea') # only allow selection in text inputs and textareas

      $('.board').on 'click', '.stack-name', () ->
        $this = $(this)
        offset = $this.offset()
        offset.left -= 1

        $input = $('<input type="text" class="stack-name-edit">').val($this.text())
        $input.appendTo($this.parent()).offset(offset).focus()
        $this.remove()

        $input.on 'blur change', () ->
          $this.text($input.val())
          $this.appendTo($input.parent())
          $input.remove()
          targetGroupId = $this.attr('id').split('-')[0]
          socket.emit 'updateGroup', {boardName: board.name, _id: targetGroupId, name: $input.val()}

      $('.card .colors .color').live 'click', () ->
        card = $(this).closest('.card')[0]
        colorIndex = $(this).attr('class').match(/color-(\d+)/)[1]
        data =  _id : card.id, colorIndex : colorIndex
        socket.emit 'color', data
        onColor data

      $('.card textarea').live 'keyup', () ->
        card = $(this).closest('.card')[0]
        socket.emit 'text', _id : card.id, text : $(this).val(), author : board.user_id
        addAuthor card.id, board.user_id
        adjustTextarea this
        return false

      $('.card textarea').live 'change', () ->
        card = $(this).closest('.card')[0]
        socket.emit 'text_commit', _id : card.id, text : $(this).val(), board_name : board.name, author : board.user_id
        if groupId = $(card).data('group-id')
          boardroom.group.layOut(groupId)

      $('.card .delete').live 'click', () ->
        card = $(this).closest('.card')[0]
        socket.emit 'delete', _id : card.id, author : board.user_id
        $(card).remove()
        return false

      $('button.create').click () -> createCard()

      @header.on 'boardTitleUpdate', (title) ->
        socket.emit 'title_changed', title: title

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
      .html("<img src='#{@avatar userId}'/>
             <span>#{@cleanHTML message}</span>")
      .show()

  createCard: ->
    @focusNextCreate = true
    socket.emit 'add',
      boardName : board.name
      author : board.user_id
      x: parseInt Math.random() * 700
      y: parseInt Math.random() * 400

  addAuthor: (cardId, author) =>
    if $("##{cardId} .authors img[title='#{author}']").length is 0
      $("##{cardId} .authors")
        .append("<img src='#{@avatar author}' title='#{@cleanHTML author}'/>")

  onCreateCard: (data) =>
    $card = $("<div class='card'>
                 <img class='delete' src='/images/delete.png'/>
                 <div class='notice'></div>
                 <div class='colors'>
                   <span class='color color-0'></span>
                   <span class='color color-1'></span>
                   <span class='color color-2'></span>
                   <span class='color color-3'></span>
                   <span class='color color-4'></span>
                 </div>
                 <textarea></textarea>
                 <div class='authors'></div>
               </div>")
      .attr('id', data._id)
      .css
        left: data.x
        top: data.y

    $('textarea', $card).val data.text
    $card.removeClassMatching /color-\d+/g
    $card.addClass "color-#{data.colorIndex || 2}"
    $('.board').append $card

    if data.authors
      $(data.authors).each (i,author) ->
        @addAuthor data._id, author
    if data.groupId
      $card.attr 'data-group-id', data.groupId

    @adjustTextarea $('textarea', $card)[0]
    if @focusNextCreate
      $('textarea', $card).focus()
      @focusNextCreate = false

    @boardroom.moveToTop $card
    $card.on 'mousedown', @boardroom.card.onMouseDown

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
    @adjustTextarea $textarea[0]
    @boardroom.moveToTop "##{data._id}"

