$.fn.extend
  fillViewport: ->
    $(this).height $(window).height() - $(this).offset().top

@viewportUpdate = ->
  $('.viewport').each ->
    $(this).fillViewport()

$(window).resize -> viewportUpdate()
