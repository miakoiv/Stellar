$.fn.extend
  fillViewport: ->
    vh = $(window).height() - $('#main-nav').outerHeight()
    $(this).css 'min-height', vh

@viewportUpdate = ->
  $('.section .viewport').each ->
    $(this).fillViewport()

$(window).on 'resize', debounce(viewportUpdate)
