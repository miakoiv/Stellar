$.fn.extend
  point_of_sale_form: () ->
    $form = this
    $product_select = $('#order_item_product_id').selectize
      dropdownParent: 'body'
      valueField: 'id'
      sortField: [{field: 'title'}, {field: 'subtitle'}]
      searchField: ['code', 'customer_code', 'title', 'subtitle']
      diacritics: false
      render: $.fn.selectize.product_renderer
      load: (query, callback) ->
        return callback() unless query
        $.ajax
          url: $form.data 'productQueryUrl'
          type: 'GET'
          dataType: 'json'
          data:
            q: query
            purposes: ['vanilla', 'composite']
            having_variants: false
          error: ->
            callback()
          success: (response) ->
            callback(response)
      onChange: (id) ->
        lot_code.clearOptions()
        if id
          lot_code.load (callback) ->
            $.ajax
              url: product_select.options[id].url
              type: 'GET'
              dataType: 'json'
              error: ->
                callback()
              success: (response) ->
                lot_code.enable()
                callback(response.inventory_items)
        else
          item_select.disable()

    $lot_code = $('#order_item_lot_code').selectize
      dropdownParent: 'body'
      valueField: 'code'
      searchField: 'code'
      maxItems: 1
      render:
        item: (item, escape) ->
          """
          <div class="item">
            <strong>\#{escape(item.code)}</strong>
            \#{if item.available? then '<i class="fa fa-cube fa-fw"></i> ' + item.available else ''}
            <span class="small">
              \#{if item.expires_at then '<i class="fa fa-hourglass-end fa-fw"></i> ' + item.expires_at else ''}
            </span>
          </div>
          """
        option: (item, escape) ->
          """
          <div class="option">
            <strong>\#{escape(item.code)}</strong>
            \#{if item.available? then '<i class="fa fa-cube fa-fw"></i> ' + item.available else ''}
            <span class="small">
              \#{if item.expires_at then '<i class="fa fa-hourglass-end fa-fw"></i> ' + item.expires_at else ''}
            </span>
          </div>
          """

    product_select = $product_select[0].selectize
    lot_code = $lot_code[0].selectize
