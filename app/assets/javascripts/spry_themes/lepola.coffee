$.fn.extend
  position_below_categories: ->
    this.css('padding-top', $('ul.categories').height() + 10)
  build_masonry: ->
    this.imagesLoaded ->
      this.masonry
        itemSelector: '.product'
        columnWidth: 190
        isAnimated: true

jQuery ->
  $('ul.products').position_below_categories().build_masonry()
