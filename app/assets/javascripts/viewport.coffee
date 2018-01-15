$.fn.extend
  fillViewport: ->
    $(this).height $(window).height() - $('.layout-container').offset().top

@viewportUpdate = ->
  $('.section-content.viewport').each ->
    $(this).fillViewport()

$(window).resize -> viewportUpdate()
