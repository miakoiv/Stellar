$(document).on 'click', '[data-view-mode]', (e) ->
  mode = $(this).data 'viewMode'
  $target = $($(this).data 'target')
  $parent = $($(this).data 'parent')
  $peers = $parent.find '[data-view-mode]'
  $peers.each ->
    $target.removeClass $(this).data 'viewMode'
  $target.addClass mode
  $peers.removeClass 'active'
  $(this).addClass 'active'
  $target.find('.masonry-grid').masonry()
