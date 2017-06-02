jQuery ->

  if $('body').hasClass 'wiselinks'
    window.wiselinks = new Wiselinks()

    #$(document).off 'page:loading'
    #  .on 'page:loading', -> NProgress.start()
    #$(document).off 'page:always'
    #  .on 'page:always', -> NProgress.done()
    #$(document).off 'page:done'
    #  .on 'page:done', (event, $target, status, url, data) ->
    #    $(document).rebuild_parallax()
    #    $(document).rebuild_masonry()
    #    ga?('send', 'pageview', window.location.pathname)
    #    fbq?('track', 'PageView')
