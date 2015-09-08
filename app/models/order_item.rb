#encoding: utf-8

class OrderItem < ActiveRecord::Base

  belongs_to :order, touch: true
  belongs_to :product

  default_scope { order(:priority) }

  #---
  def subtotal
    amount * (price || 0)
  end

  def is_shipping_cost?
    product == order.store.shipping_cost_product
  end

  def archive!
    update(
      product_code: product.code,
      product_customer_code: product.customer_code,
      product_title: product.title,
      product_subtitle: product.subtitle
    )
  end
end
