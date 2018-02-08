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
        item_select.clearOptions()
        entry_select.clearOptions()
        if id
          item_select.load (callback) ->
            $.ajax
              url: product_select.options[id].url
              type: 'GET'
              dataType: 'json'
              error: ->
                callback()
              success: (response) ->
                item_select.enable()
                callback(response.inventory_items)
                $item_select.data 'entries', response.inventory_entries
        else
          item_select.disable()
          entry_select.disable()

    $item_select = $('#order_item_inventory_item_id').selectize
      dropdownParent: 'body'
      allowEmptyOption: true
      valueField: 'id'
      labelField: 'code'
      searchField: 'code'
      onChange: (id) ->
        entry_select.clearOptions()
        if id
          entry_select.enable()
          entry_select.addOption $item_select.data('entries')[id]
        else
          entry_select.disable()

    $entry_select = $('#order_item_inventory_entry_id').selectize
      dropdownParent: 'body'
      allowEmptyOption: true
      valueField: 'id'
      labelField: 'serial_number'

    product_select = $product_select[0].selectize
    item_select = $item_select[0].selectize
    entry_select = $entry_select[0].selectize
