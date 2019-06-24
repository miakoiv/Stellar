$.fn.extend
  nouislider: (options) ->
    this.each ->
      $control = $(this)
      $group = $control.parent()
      settings = $.extend {
        start: Number $control.val()
        step: Number $control.attr 'step'
        range:
          min: Number $control.attr 'min'
          max: Number $control.attr 'max'
        tooltips: wNumb({decimals: 0})
        format: wNumb({decimals: 0})
      }, options
      $control.hide()
      $container = $('<div>').appendTo $group
      noUiSlider.create $container[0], settings
      .on 'set', ->
        $control.val this.get()
        $control.trigger 'change'
