$.fn.extend
  initialize: ->

    $('.gallery').each ->
      $(this).magnificPopup
        delegate: '.image-link'
        type: 'image'
        gallery:
          enabled: true

    $('[data-toggle="tooltip"]').tooltip()
    $('[data-toggle="popover"]').popover
      html: true
      trigger: 'hover'

    $('.select2', this).select2
      width: 'resolve'
      dropdownAutoWidth: true

jQuery ->

  $(document).initialize()

  $(document).on 'change', 'form.immediate', (e) ->
    $(e.currentTarget).trigger('submit.rails')
