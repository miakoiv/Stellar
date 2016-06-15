(function() {

    $.fn.gridEditor.RTEs.summernote = {

        init: function(settings, contentAreas) {

            if (!jQuery().summernote) {
                console.error('Summernote not available! Make sure you loaded the Summernote js file.');
            }

            var self = this;
            contentAreas.each(function() {
                var contentArea = $(this);
                if (!contentArea.hasClass('active')) {
                    if (contentArea.html() == self.initialContent) {
                        contentArea.html('');
                    }
                    contentArea.addClass('active');

                    var configuration = $.extend(
                        (settings.summernote && settings.summernote.config ? settings.summernote.config : {}),
                        {
                            tabsize: 2,
                            airMode: true,
                            // Focus editor on creation
                            callbacks: {
                                onInit: function() {
                                    contentArea.summernote('focus');

                                    if (settings.summernote.config.onInit && typeof settings.summernote.config.onInit == 'function') {
                                      settings.summernote.config.onInit();
                                    }
                                }
                            }
                        }
                    );
                    contentArea.summernote(configuration);
                }
            });
        },

        deinit: function(settings, contentAreas) {
            contentAreas.filter('.active').each(function() {
                var contentArea = $(this);
                contentArea.summernote('destroy');
                contentArea
                    .removeClass('active')
                    .removeAttr('id')
                    .removeAttr('style')
                    .removeAttr('spellcheck')
                ;
            });
        },

        initialContent: '<p>Lorem ipsum dolores</p>',
    };
})();
