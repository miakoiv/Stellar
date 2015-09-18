jQuery ->
  top = $('.categories').height() + 10
  $('.products')
    .css('padding-top', top)
    .imagesLoaded ->
      this.masonry
        itemSelector: '.product'
        columnWidth: 190
  $('.product-detail').css('padding-top', top)
