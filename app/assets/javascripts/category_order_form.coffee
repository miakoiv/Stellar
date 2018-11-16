$.fn.extend
  category_order_form: (order_items_url)->
    $element = this
    $.ajax
      type: 'GET'
      url: order_items_url
      dataType: 'json'
      success: (response) ->
        for item in response.order_items
          $field = $element.find "#set_order_amount_product_#{item.product_id}"
          $field.val item.amount
