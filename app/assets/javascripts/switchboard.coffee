class Switchboard

  @formats =
    '1': 'GS1-128'

  @mapping =
    'Dead': String.fromCharCode(29) # ctrl-] to FNC1

  constructor: (element, @options) ->
    @state = 0

    # Switchboard state machine
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
          @format = Switchboard.formats[k]
          @state = 2
        when 2
          e.preventDefault()
          if k is 'Enter'
            @state = 0
            @options.callbacks[@format](@capture)
          else
            @capture += Switchboard.mapping[k] || k
        else
          console.log "Unknown state #{@state}"

    element.focus()

$.fn.switchboard = (options) ->
    this.switchboard = new Switchboard this, options
