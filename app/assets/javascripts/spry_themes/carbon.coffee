@carbon_init = ->
  $('#masthead').css 'height', $(window).height()
  $('#main-nav').stick_in_parent
    offset_top: -30

jQuery ->
  carbon_init()
  $(document).on 'page:done', carbon_init
