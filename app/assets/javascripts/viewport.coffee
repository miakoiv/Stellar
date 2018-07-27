$.fn.extend
  fillViewport: ->
    $(this).height $(window).height() - $('#main-nav').outerHeight()

@viewportUpdate = ->
  $('.section-content.viewport').each ->
    $(this).fillViewport()

$(window).resize -> viewportUpdate()
