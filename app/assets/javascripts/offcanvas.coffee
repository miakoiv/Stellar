$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $target = $($(this).data 'target')
  $target.toggleClass 'open'
  event = if $target.hasClass 'open' then 'shown' else 'hidden'
  $target.trigger event
