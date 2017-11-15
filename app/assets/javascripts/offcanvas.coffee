$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $target = $($(this).data 'target')
  $target.toggleClass 'open'
  $(e.currentTarget).closest('.offcanvas-toggle').toggleClass 'is-active'
  event = if $target.hasClass 'open' then 'shown' else 'hidden'
  $target.trigger event
