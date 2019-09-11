$.fn.extend
  loadPartial: ->
    e = this
    url = e.data 'url'
    e.addClass 'is-loading'
    $.ajax
      url: url
      dataType: 'script'
    .fail (xhr, status, err) ->
      console.log err
    .always ->
      e.removeClass 'is-loading'
