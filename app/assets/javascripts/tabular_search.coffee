$.fn.extend
  tabular_search_widget: ->
    this.find '.tabular-header input'
      .attr 'placeholder', ''
      .wrap '<div class="form-group has-feedback">'
      .after '<span class="form-control-feedback"><i class="fa fa-search"></i></span>'
