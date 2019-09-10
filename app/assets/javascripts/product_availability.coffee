# Call checkAvailability on a set of 'add to cart' widgets to disable the set,
# then fetch stock data from [data-url] of each widget to enable it when
# there is available stock. If the widget specifies an element selector in
# [data-update], auxiliary elements inside may be shown depending on back order
# availability.

$.fn.extend
  checkAvailability: ->
    this.addClass 'disabled'
    this.each (i, e) ->
      $widget = $(e)
      url = $widget.data 'url'
      update = $widget.data 'update'
      $.ajax
        url: url
        dataType: 'json'
      .done (data) ->
        # infinity becomes null in the JSON
        if !data.available? or data.available > 0
          $widget.removeClass 'disabled'
        else
          if data.backOrder
            $widget.removeClass 'disabled'
            if update then $(update).find('.back-orderable').collapse 'show'
          else
            if update then $(update).find('.out-of-stock').collapse 'show'
