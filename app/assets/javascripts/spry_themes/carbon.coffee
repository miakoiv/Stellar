jQuery ->
  @stick_main_nav = ->
    $('#main-nav').stick_in_parent
      offset_top: -30
  @stick_main_nav()
  $(document).on 'page:done', @stick_main_nav
