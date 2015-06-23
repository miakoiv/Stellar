$.fn.extend
  initialize: ->
    $('.select2', this).select2
      width: 'resolve'
      dropdownAutoWidth: true

jQuery ->

  $(document).initialize()

  $('.gallery').magnificPopup
    delegate: '.image-link'
    type: 'image'
    gallery:
      enabled: true
