@stick_main_nav = ->
  $('#main-nav').stick_in_parent
    offset_top: -30

@resize_masthead = ->
  $('#masthead').css 'height', $(window).height()

jQuery ->
  resize_masthead()
  stick_main_nav()
  $(window).on 'resize', resize_masthead
  $(document).on 'page:done', stick_main_nav
