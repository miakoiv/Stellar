jQuery ->
  top = $('#main-nav').height() + 4
  $('.hiustalo').css('padding-top', top)

  $('.products').imagesLoaded ->
    this.masonry
      itemSelector: '.product'
      gutterWidth: 15
