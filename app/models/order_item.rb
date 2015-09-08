#encoding: utf-8

class OrderItem < ActiveRecord::Base

  belongs_to :order, touch: true
  belongs_to :product

  #---
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
