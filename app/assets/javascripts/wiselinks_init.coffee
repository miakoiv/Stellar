jQuery ->

  if $('body').hasClass 'wiselinks'
    window.wiselinks = new Wiselinks()

    $(document).on 'page:loading', -> NProgress.start()
    $(document).on 'page:always', -> NProgress.done()
    $(document).on 'page:done', (event, $target, status, url, data) ->
      $(document).rebuild_parallax()
      $(document).rebuild_masonry()
      ga?('send', 'pageview', window.location.pathname)
      fbq?('track', 'PageView')
