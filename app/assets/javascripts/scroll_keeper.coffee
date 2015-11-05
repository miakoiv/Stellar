@ScrollKeeper =
  activate: ->
    @restore()
    $('a[data-keep="scroll"]').on 'click', (event) =>
      @keep()

  keep: ->
    localStorage.setItem @key, $(window).scrollTop()

  restore: ->
    $(window).scrollTop localStorage.getItem(@key)

  key: location.pathname
