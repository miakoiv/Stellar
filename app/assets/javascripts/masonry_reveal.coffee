$.fn.masonryReveal = ($items) ->
  masonry = this.data 'masonry'
  selector = masonry.options.itemSelector
  $items.hide()
  this.append $items
  $items.imagesLoaded ->
    $items.show()
    masonry.appended $items
