$(document).on 'show.bs.offcanvas', '.offcanvas', ->
  $('body').css 'overflow', 'hidden'
  $('body').on 'touchmove.bs', (e) ->
    if not $(e.target).closest '.offcanvas'
      e.preventDefault()
      e.stopPropagation()

$(document).on 'hidden.bs.offcanvas', '.offcanvas', ->
  $('body').css 'overflow', 'auto'
  $('body').off 'touchmove.bs'
