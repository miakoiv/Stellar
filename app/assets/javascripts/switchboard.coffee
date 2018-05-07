class Switchboard

  # Options available/expected:
  # mapping: hash of translations performed on the captured keydown events
  #          to convert from the HID conventions to actual barcode data,
  #          for example {'Dead': String.fromCharCode(29)} to map the FI/SE
  #          dead key to GS1-128 FNC1 control code
  # callback: function to postprocess captured data
  #
  constructor: (id, @options) ->
    @element = document.getElementById id
    @mapped = (key for key, _ of @options.mapping)

    @element.addEventListener 'keydown', (e) =>
      k = e.key

      if k in @mapped
        e.preventDefault()
        @element.value = @element.value + @options.mapping[k]

      if k is 'Enter'
        e.preventDefault()
        code = @element.value
        callback = @options.callback
        callback?(code)
      if k is 'Backspace'
        @element.value = ''

    @element.focus()

(exports ? this).Switchboard = Switchboard
