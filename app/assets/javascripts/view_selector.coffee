#
# Click handler for view mode buttons
#
# Switchable view modes are implemented with buttons arranged
# inside an element that is declared the parent. Each button
# specifies the target for which the view mode will change,
# and the mode itself.
#
# The target has a view-key data attribute used as a hash key
# in the view mode settings cookie.
#
$(document).on 'click', '[data-view-mode]', (e) ->
  mode = $(this).data 'viewMode'
  $target = $($(this).data 'target')
  $parent = $($(this).data 'parent')
  $peers = $parent.find '[data-view-mode]'

  # Clear all view mode classes from target, and deactivate the buttons.
  $peers.each ->
    $target.removeClass $(this).data 'viewMode'
  $peers.removeClass 'active'

  # Add the view mode class to target, activate pushed button.
  $target.addClass mode
  $(this).addClass 'active'

  # Update view mode settings cookie.
  settings = Cookies.getJSON('view_mode_settings') or {}
  key = $target.data 'viewKey'
  settings[key] = mode
  Cookies.set 'view_mode_settings', settings

  $target.imagesLoaded ->
    $target.find('.masonry-grid').masonry('layout')
