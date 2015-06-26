$.fn.extend
  initialize: ->

    $('[data-toggle="popover"]').popover
      html: true
      trigger: 'hover'

    $('.select2', this).select2
      width: 'resolve'
      dropdownAutoWidth: true

    $(document).on 'change', 'form.immediate', (e) ->
      $(e.currentTarget).trigger('submit.rails')

jQuery ->

  $(document).initialize()

  $('.gallery').magnificPopup
    delegate: '.image-link'
    type: 'image'
    gallery:
      enabled: true
