$ ->
  placeholder = ->
    $input = $('#board-name')
    $submit = $input.closest('form').find('button')
    $input.placeholder $submit

  placeholder()

  $('.copy-url').each ->
    $(@).zclip
      path: '/swf/ZeroClipboard.swf'
      copy: window.document.location.href + $(@).closest('li').find('.info a').attr('href').slice(1)
      afterCopy: ->
        el_shown = $('.copy-url a').filter ->
          $(@).data('tooltip').isShown(true)
        tooltip_api = el_shown.data 'tooltip'
        tooltip_api.getTip().html('URL copied!')

  $('.zclip').each ->
    $(@).mouseover ->
      $(@).closest('.actions').find('.copy-url a').mouseover()

    $(@).mouseout ->
      $(@).closest('.actions').find('.copy-url a').mouseout()
