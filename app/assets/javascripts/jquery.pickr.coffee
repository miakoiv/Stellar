$.fn.extend
  pickr: (options = {}) ->
    settings = $.extend {}, {
      container: 'body'
      position: 'bottom-end'
      theme: 'nano'
      swatches: ['#000', '#fff', 'transparent']
      components:
        preview: true
        opacity: true
        hue: true
        interaction:
          input: true
          save: true
      strings:
        save: 'OK'
    }, options
    this.each ->
      $input = $(this)
      $group = $input.parent()
      $chip = $('<div>', class: 'pickr')
      $chip.appendTo $group
      new Pickr(
        $.extend settings, {el: $chip[0], default: $input.val()}
      ).on 'save', (c, p) ->
        $input.val c.toRGBA().toString().toLowerCase()
        $input.trigger 'change'
