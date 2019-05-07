$.fn.extend
  initViewport: ->
    vh = $(window).height() - $('#main-nav').outerHeight()
    $(this).css 'min-height', vh

@viewportUpdate = ->
  $('.viewport').each ->
    $(this).initViewport()

$(window).on 'resize', debounce(viewportUpdate)
