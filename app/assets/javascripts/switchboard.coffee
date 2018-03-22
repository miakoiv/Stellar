class Switchboard

  # Options available/expected:
  # formats: hash of accepted barcode formats keyed by symbology identifier,
  #          for example {']C1': 'GS1-128'}
  # mapping: hash of translations performed on the captured keydown events
  #          to convert from the HID conventions to actual barcode data,
  #          for example {'Dead': String.fromCharCode(29)} to map the FI/SE
  #          dead key to GS1-128 FNC1 control code
  # callbacks: hash of functions keyed by format to postprocess captured data
  #
  constructor: (id, @options) ->
    @element = document.getElementById id
    @mapped = (key for key, _ of @options.mapping)

    @element.addEventListener 'keydown', (e) =>
      k = e.key

      if k in @mapped
        e.preventDefault()
        @element.value = @element.value + @options.mapping[k]

    @element.addEventListener 'keypress', (e) =>
      if e.key is 'Enter'
        e.preventDefault()
        code = @element.value
        ident = code.substr 0, 3
        format = @options.formats[ident]
        callback = @options.callbacks[format]
        callback?(code)
      if e.key is 'Backspace'
        @element.value = ''

    @element.focus()

(exports ? this).Switchboard = Switchboard
