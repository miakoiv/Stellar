@BLANK_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs='

$.fn.selectize.product_renderer =
  item: (item, escape) ->
    """
    <div>
      <img src="#{item.icon_image_url || BLANK_IMAGE}" alt="">
      <strong>#{escape(item.title)}</strong>
      #{if item.subtitle then escape(item.subtitle) else ''}
    </div>
    """
  option: (item, escape) ->
    """
    <div class="list-group-item">
      <div class="pull-right">
        <span class="small">
          #{if item.customer_code then escape(item.customer_code) else ''}
        </span>
        <span class="label label-default">
          #{escape(item.code)}
        </span>
      </div>
      <img src="#{item.icon_image_url || BLANK_IMAGE}" alt="">
      <strong>#{escape(item.title)}</strong>
      #{if item.subtitle then escape(item.subtitle) else ''}
    </div>
    """
