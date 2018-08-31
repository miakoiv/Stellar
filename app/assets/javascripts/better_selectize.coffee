# Activates selectize on .selectize controls with default
# options, adding the remove_button plugin if the control
# is multiple selection, or has an empty first option.
$.fn.extend
  betterSelectize: (options) ->
    this.each ->
      $control = $(this)
      settings = $.extend {}, {plugins: [], dropdownParent: 'body'}, options
      if settings.remove or
          $control.is('select') and ($control.prop('multiple') or
            $control.prop('options').item(0)?.value == '')
        settings.plugins.push 'remove_button'
      $control.selectize settings

  destroySelectized: ->
    $('.selectized', this).each ->
      this.selectize.destroy()
