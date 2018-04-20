$.fn.extend
  fillViewport: ->
    $(this).height $(window).height() - $('#main-nav').outerHeight() - $('#page-nav').outerHeight()

@viewportUpdate = ->
  $('.section-content.viewport').each ->
    $(this).fillViewport()

$(window).resize -> viewportUpdate()
