$.fn.extend
  dynamicNavbar: ->
    static_class = this.data 'navbar-static-class'
    fixed_class = this.data 'navbar-fixed-class'
    this.addClass static_class
    observer = new IntersectionObserver (entries, observer) =>
      if entries[0].isIntersecting
        this.removeClass static_class
        this.addClass fixed_class
      else
        this.removeClass fixed_class
        this.addClass static_class
    observer.observe document.getElementById('dynamic-navbar-breakpoint')

jQuery ->
  $('.navbar-dynamic').each ->
    $(this).dynamicNavbar()
