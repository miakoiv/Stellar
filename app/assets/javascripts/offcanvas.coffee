$.fn.extend
  offcanvas: (action) ->
    $toggle = this
    $target = $(this.data 'target')
    if action is 'toggle'
      action = if $target.hasClass 'open' then 'hide' else 'show'
    if action is 'show'
      $target.addClass 'open'
      $target.trigger 'shown'
      $toggle.addClass 'is-active'
    else
      $target.removeClass 'open'
      $target.trigger 'hidden'
      $toggle.removeClass 'is-active'

  scrollMenu: (context) ->
    if this.length
      position = this.position().top
      context.animate
        scrollTop: position - $('#main-nav').height()
        200

$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $toggle = $(this)
  $toggle.offcanvas 'toggle'

$(document).on 'click', '#side-nav .scroll > a', ->
  $('.offcanvas-toggle').offcanvas 'hide'
