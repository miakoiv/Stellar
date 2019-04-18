json.extract! @shipment, :id, :shipped_at
json.order_number @shipment.order.number
json.extract! @shipment, :tracking_code, :pickup_point_id, :package_type, :mass
json.extract! @shipment.order, :customer_email
json.extract! @shipment.shipping_method, :shipping_gateway
json.extract! @shipment.order.billing_address, :company, :department, :name, :address1, :address2, :postalcode, :city, :country_code, :phone
json.shipment_items do
  json.array!(@shipment.transfer.transfer_items) do |transfer_item|
    json.product_code transfer_item.product.code
    json.product_title transfer_item.product.to_s
    json.extract! transfer_item, :lot_code, :amount
    json.price transfer_item.order_item.price.to_s
  end
end
