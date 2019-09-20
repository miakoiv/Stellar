$.fn.extend
  preloadSections: ->
    for section in this.data 'sections'
      $.get section

@startLayout = ->
  $(document).on 'pictureable:added pictureable:changed pictureable:removed pictureable:reordered documentable:added documentable:removed documentable:reordered videoable:added videoable:changed videoable:removed videoable:reordered', ->
    $('.event-hook').trigger 'submit.rails'

  $(document).on 'hidden.bs.modal', (e) ->
    $('.section, .column, .segment').removeClass('active');
