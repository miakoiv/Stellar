class Switchboard

  #
  # Options available/expected:
  # formats: hash of accepted barcode formats keyed by symbology identifier,
  #          for example {'1': 'GS1-128'}
  # mapping: hash of translations performed on the captured keydown events
  #          to convert from the HID conventions to actual barcode data,
  #          for example {'Dead': String.fromCharCode(29)} to map the FI/SE
  #          dead key to GS1-128 FNC1 control code
  # callbacks: hash of functions keyed by format to postprocess captured data
  #
  constructor: (element, @options) ->
    @state = 0

    # Switchboard state machine:
    # 0: [idle] ctrl-a triggers barcode capture
    # 1: [start] awaiting format identifier
    # 2: [capture] Enter terminates and calls back with captured data
    element.on 'keydown', (e) =>
      k = e.key
      return if k is 'Control' or k is 'Shift'

      switch @state
        when 0
          if k is 'a' and e.ctrlKey
            @state = 1
            @format = undefined
            @capture = ''
        when 1
          e.preventDefault()
          @format = @options.formats[k]
          @state = 2
        when 2
          e.preventDefault()
          if k is 'Enter'
            @state = 0
            @options.callbacks[@format](@capture)
          else
            @capture += @options.mapping[k] || k
        else
          console.log "Unknown state #{@state}"

    element.focus()

$.fn.switchboard = (options) ->
    this.switchboard = new Switchboard this, options
