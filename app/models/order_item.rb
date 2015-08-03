#encoding: utf-8

class OrderItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :product

  # Takes an inventory item from Store#stock_lookup and adjusts
  # its adjustment attribute according to amount of product
  # in orders concerning the specified inventory.
  def self.adjust!(inventory_item)
    joins(:product, order: {order_type: :inventory})
        .where(products: {code: inventory_item.code})
        .where(inventories: {id: inventory_item.inventory}).each do |item|
      order_type = item.order.order_type
      multiplier = order_type.adjustment_multiplier
      inventory_item.adjust!(multiplier * item.amount)
    end
    inventory_item
  end


  def subtotal
    amount * (product.sales_price || 0)
  end

  def archive!
    update(
      product_code: product.code,
      product_customer_code: product.customer_code,
      product_title: product.title,
      product_subtitle: product.subtitle,
      product_sales_price: product.sales_price
    )
  end
end
