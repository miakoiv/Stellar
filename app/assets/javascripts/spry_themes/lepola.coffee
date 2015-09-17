jQuery ->

  $('ul.products').css(
    'padding-top', $('ul.categories').height()
  )

  $products = $('ul.products').masonry
    itemSelector: 'li.product'
    columnWidth: 200

  $products.imagesLoaded().progress ->
    $products.masonry('layout')
