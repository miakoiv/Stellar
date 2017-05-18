$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $canvas = $($(this).data 'canvas')
  $canvas.toggleClass 'canvas-slid'
  $(window).scrollTo $canvas, 150
