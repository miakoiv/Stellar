# Call checkFavorites on a set of buttons with a url argument to
# fetch a set of favorites, and selectively enable the buttons that
# specify a product id in [data-id] that is not included in the set.

$.fn.extend
  checkFavorites: (url) ->
    buttons = this
    $.ajax
      url: url
      dataType: 'json'
    .done (data) ->
      buttons.each (i, button) ->
        id = $(button).data 'id'
        if data.indexOf(id) is -1
          $(button).removeClass 'disabled'
