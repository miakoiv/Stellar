$.fn.extend
  segment_dragdrop: ->
    this.draggable
      scope: 'segments'
      addClasses: false
      revert: 'invalid'
      handle: '.drag-handle'
      helper: 'clone'
      opacity: 0.6
      appendTo: '#content-wrap'
      start: (e, ui) ->
        $source = $(this)
        $payload = ui.helper
        $payload.css
          width: $source.css 'width'
          paddingTop: $source.css 'paddingTop'
          paddingRight: $source.css 'paddingRight'
          paddingBottom: $source.css 'paddingBottom'
          paddingLeft: $source.css 'paddingLeft'
    .droppable
      scope: 'segments'
      addClasses: false
      accept: '.segment'
      tolerance: 'pointer'
      drop: (e, ui) ->
        $segment = $(this)
        $payload = $(ui.draggable[0])
        $.ajax
          url: $segment.data 'dragdropUrl'
          type: 'POST'
          data:
            other_id: $payload.data 'id'
