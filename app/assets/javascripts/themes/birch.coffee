jQuery ->
  (@setup = ->
    $('#categories-wrap').make_room $('#categories-wrap li.category.active > .subcategories-wrap')
  )()
  $(document).on 'page:done', (event, $target, status, url, data) -> @setup()
