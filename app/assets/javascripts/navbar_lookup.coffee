$.fn.extend
  navbarLookup: (options) ->
    $lookup = this
    $widget = $(options.widget)
    $dropdown = $(options.dropdown)
    url = $('form', $lookup).attr 'action'

    # install event handlers to switch widgets on open/close
    $lookup.on 'shown.bs.collapse', (e) ->
      $('input', this).focus()
      $widget.find('.lookup-open').hide()
      $widget.find('.lookup-close').show()
    $lookup.on 'hidden.bs.collapse', (e) ->
      $widget.find('.lookup-close').hide()
      $widget.find('.lookup-open').show()

    # hide lookup when side nav is opened
    $('#side-nav').on 'shown.offcanvas', (e) =>
      this.collapse 'hide'

    # prevent form submit and hook up smartkeyup to the input
    $('form', this).on 'submit', (e) =>
      e.preventDefault()
    $('#keyword').smartkeyup (e) ->
      q = $(this).val().replace /^\s+|\s+$/g, ''
      if e.keyCode is 27
        $lookup.collapse 'hide'
      else if q?.length > 1
        $.get url, {keyword: q}
      else
        $dropdown.hide 'fade'
