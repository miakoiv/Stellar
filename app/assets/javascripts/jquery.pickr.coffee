$.fn.extend
  pickr: (options = {}) ->
    settings = $.extend {}, {
      container: 'body'
      position: 'bottom-end'
      theme: 'nano'
      swatches: ['transparent', '#000', '#333', '#666', '#999', '#ccc', '#fff']
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
      ).on 'changestop', (p) ->
        p.applyColor()
      .on 'swatchselect', (c, p) ->
        p.applyColor()
      .on 'save', (c, p) ->
        $input.val c.toRGBA().toString(0).toLowerCase()
        $input.trigger 'change'
