$(document).on 'click', '[data-toggle="offcanvas"]', (e) ->
  $canvas = $($(this).data 'canvas')
  $canvas.toggleClass 'canvas-slid'
  $(window).scrollTo $canvas, 150

$(window).on 'load resize', (e) ->
  height = Math.max $('#canvas-wrap').height(), $('#offcanvas .inner-wrap').height()
  $('#canvas-wrap').height height
