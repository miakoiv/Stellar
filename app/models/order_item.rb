#encoding: utf-8

class OrderItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :product


  def self.adjust_stock!(stock, code)
    joins(:product, order: :order_type)
        .where(products: {code: code}).each do |item|
      order_type = item.order.order_type
      multiplier = order_type.adjustment_multiplier
      stock[order_type.inventory.purpose][:adjustment] += multiplier * item.amount
    end
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
