$.fn.extend
  column_sortable: ->
    this.sortable(
      connectWith: '.column'
      items: '> .segment'
      handle: '.segment-handle'
      placeholder: 'sortable-placeholder'
      forcePlaceholderSize: true
      opacity: 0.5
      revert: 200
    ).bind 'sortupdate', (e, ui) ->
      $.post $(this).data('reorder'),
        {reorder: $(this).sortable('toArray')}
