jQuery ->

  $('.gallery').magnificPopup
    delegate: '.image-link'
    type: 'image'
    gallery:
      enabled: true

  $('.select2').select2({width: 'resolve'})
