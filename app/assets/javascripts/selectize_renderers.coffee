@BLANK_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs='

$.fn.selectize.product_renderer =
  item: (item, escape) ->
    """
    <div class="item">
      <img src="#{item.icon_image_url || BLANK_IMAGE}" alt="">
      <strong>#{escape(item.title)}</strong>
      #{if item.subtitle then escape(item.subtitle) else ''}
    </div>
    """
  option: (item, escape) ->
    """
    <div class="option list-group-item">
      <div class="pull-right">
        <span class="small">
          #{if item.customer_code then escape(item.customer_code) else ''}
        </span>
        <span class="badge">
          #{escape(item.code)}
        </span>
      </div>
      <img src="#{item.icon_image_url || BLANK_IMAGE}" alt="">
      <strong>#{escape(item.title)}</strong>
      #{if item.subtitle then escape(item.subtitle) else ''}
    </div>
    """

$.fn.selectize.inventory_renderer =
  option_create: (data, escape) ->
    '<div class="create no-wrap"><i class="fa fa-fw fa-plus-circle"></i> ' + escape(data.input) + '</div>'
  item: (item, escape) ->
    """
    <div class="item">
      <strong>#{escape(item.code)}</strong>
      #{if item.available? then '<span class="no-wrap"><i class="fa fa-cube fa-fw"></i> ' + item.available + '</span>' else ''}
      <span class="small no-wrap">
        #{if item.expires_at then '<i class="fa fa-hourglass-end fa-fw"></i>&#160;' + item.expires_at else ''}
      </span>
    </div>
    """
  option: (item, escape) ->
    """
    <div class="option">
      <strong>#{escape(item.code)}</strong>
      #{if item.available? then '<span class="no-wrap"><i class="fa fa-cube fa-fw"></i> ' + item.available + '</span>' else ''}
      <span class="small no-wrap">
        #{if item.expires_at then '<i class="fa fa-hourglass-end fa-fw"></i>&#160;' + item.expires_at else ''}
      </span>
    </div>
    """

$.fn.selectize.label_renderer =
  item: (item, escape) ->
    """
    <div class="item label label-#{item.appearance}">
      #{escape(item.title)}
    </div>
    """
  option: (item, escape) ->
    """
    <div class="option">
      <span class="label label-#{item.appearance}">
        #{escape(item.title)}
      </span>
    </div>
    """
