jQuery ->
  $('.products')
    .imagesLoaded ->
      this.masonry
        itemSelector: '.product'
        gutterWidth: 15
