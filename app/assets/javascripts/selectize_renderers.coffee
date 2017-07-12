$.fn.selectize.renderers =
  item: (item, escape) ->
    """
      <div>
        #{item.image_html}
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
      #{item.image_html}
      <strong>#{escape(item.title)}</strong>
      #{if item.subtitle then escape(item.subtitle) else ''}
    </div>
    """
