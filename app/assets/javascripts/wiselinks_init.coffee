jQuery ->

  if $('body').hasClass 'wiselinks'
    window.wiselinks = new Wiselinks $('#content-wrap')
    Wiselinks.scrollTop = true

    originalCall = window._Wiselinks.Page.prototype._call
    window._Wiselinks.Page.prototype._call = (state) ->
      return if Wiselinks.skipLoadingPage
      originalCall.apply(this, arguments)

    originalLoad = window._Wiselinks.Page.prototype.load
    window._Wiselinks.Page.prototype.load = (url, target, render = 'template') ->
      stateData = History.getState().data || {}
      stateData.scrollX = window.scrollX
      stateData.scrollY = window.scrollY
      Wiselinks.skipLoadingPage = true
      History.replaceState(stateData, document.title, document.location.href);
      Wiselinks.skipLoadingPage = false
      originalLoad.apply(this, arguments)

    Wiselinks.setScrollTop = ->
      if !($(this).data('scroll') == false)
        Wiselinks.scrollTop = true
    $(document)
      .off('click', 'a[data-push]', Wiselinks.setScrollTop)
      .on('click', 'a[data-push]', Wiselinks.setScrollTop)

    Wiselinks.scrollPage = ->
      stateData = History.getState().data
      if Wiselinks.scrollTop
        window.scroll(0,0)
        Wiselinks.scrollTop = false
      else if stateData? && stateData.scrollY?
        window.scroll(stateData.scrollX, stateData.scrollY)

    $(document).off 'page:loading'
      .on 'page:loading', -> NProgress.start()
    $(document).off 'page:always'
      .on 'page:always', ->
        NProgress.done()
        Wiselinks.scrollPage()
    $(document).off 'page:done'
      .on 'page:done', (event, $target, status, url, data) ->
        $(document).rebuild_parallax()
        $(document).rebuild_masonry()
        ga?('send', 'pageview', window.location.pathname)
        fbq?('track', 'PageView')
