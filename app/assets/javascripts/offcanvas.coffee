$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $target = $($(this).data 'target')
  $target.toggleClass 'open'
