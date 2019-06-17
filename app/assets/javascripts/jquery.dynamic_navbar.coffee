$.fn.extend
  makeNavbarStatic: ->
    this.removeClass this.data('navbar-fixed-class')
    this.addClass this.data('navbar-static-class')
  makeNavbarFixed: ->
    this.removeClass this.data('navbar-static-class')
    this.addClass this.data('navbar-fixed-class')

  dynamicNavbar: ->
    this.addClass this.data('navbar-static-class')
    observer = new IntersectionObserver (entries, observer) =>
      if entries[0].isIntersecting
        this.makeNavbarFixed()
      else
        this.makeNavbarStatic()
    observer.observe document.getElementById('dynamic-navbar-breakpoint')

jQuery ->
  $('.navbar-dynamic').each ->
    $(this).dynamicNavbar()
