$.fn.extend
  activateMetisMenu: ->
    offcanvas = $(this).parents '.offcanvas'
    $(this).metisMenu()
    .on 'shown.metisMenu', (e) ->
      $(e.target).parent().scrollMenu offcanvas
    $(this).find('.active').scrollMenu offcanvas
