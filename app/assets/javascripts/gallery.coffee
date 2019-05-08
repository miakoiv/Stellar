$.fn.extend
  initGallery: ->
    items = this.find '.gallery-item'
    minWidth = parseInt this.data 'minWidth'
    gutter = parseInt this.data 'gutter'
    track = this.width()
    n = Math.floor (track + gutter) / (minWidth + gutter)
    n = 1 if n < 1
    n = items.length if n > items.length
    width = (track - gutter * (n - 1)) / n
    items.css width: width, marginBottom: gutter

    masonry = this.data 'masonry'
    if this.hasClass 'masonry'
      if masonry
        masonry.layout()
      else
        this.imagesLoaded =>
          this.masonry
            itemSelector: '.gallery-item'
            gutter: gutter
    else
      masonry?.destroy()

@galleryUpdate = ->
  $('.gallery-wrap').each ->
    $(this).initGallery()

$(window).on 'resize', debounce(galleryUpdate)
