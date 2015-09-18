jQuery ->
  $('.products')
    .css('padding-top', $('.categories').height() + 10)
    .imagesLoaded ->
      this.masonry
        itemSelector: '.product'
        columnWidth: 190
