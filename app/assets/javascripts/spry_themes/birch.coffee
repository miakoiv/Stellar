jQuery ->
  $('#categories-wrap').make_room $('#categories-wrap > .categories > ul > li.category.active > .subcategories-wrap')
  $(document).on 'page:done', (event, $target, status, url, data) ->
    $('#categories-wrap').make_room $('#categories-wrap > .categories > ul > li.category.active > .subcategories-wrap')
