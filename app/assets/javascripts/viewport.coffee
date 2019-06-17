$.fn.extend
  initViewport: ->
    vh = $(window).height()
    nh = $('#main-nav').outerHeight()
    h = if $('#main-nav').hasClass 'navbar-dynamic' then vh else vh - nh
    this.css minHeight: h

@viewportUpdate = ->
  $('.viewport').each ->
    $(this).initViewport()

$(window).on 'resize', debounce(viewportUpdate)
