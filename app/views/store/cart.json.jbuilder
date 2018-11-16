json.order_items do
  json.array! @order.order_items, :id, :product_id, :amount
end
