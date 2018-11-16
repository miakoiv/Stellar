json.extract! @order, :id, :user_id, :order_type_id
json.order_items do
  json.array! @order.order_items, :id, :product_id, :amount
end
