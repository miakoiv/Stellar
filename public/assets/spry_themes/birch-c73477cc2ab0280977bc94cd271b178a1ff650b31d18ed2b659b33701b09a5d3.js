(function() {
  jQuery(function() {
    (this.setup = function() {
      return $('#categories-wrap').make_room($('#categories-wrap li.category.active > .subcategories-wrap'));
    })();
    return $(document).on('page:done', function(event, $target, status, url, data) {
      return this.setup();
    });
  });

}).call(this);
