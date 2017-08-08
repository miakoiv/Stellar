$.fn.extend
  animateCss: (effect, callback) ->
    end = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'
    @.addClass "animated #{effect}"
      .one end, ->
        $(this).removeClass "animated #{effect}"
        callback? @
