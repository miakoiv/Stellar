(function() {
  jQuery(function() {
    this.stick_page_nav = function() {
      return $('#page-nav').stick_in_parent({
        offset_top: $('#main-nav').outerHeight()
      });
    };
    this.stick_page_nav();
    return $(document).on('page:done', this.stick_page_nav);
  });

}).call(this);
