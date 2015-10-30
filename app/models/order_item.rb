#encoding: utf-8

class OrderItem < ActiveRecord::Base

  include Adjustable
  monetize :price_cents, allow_nil: true

  #---
  belongs_to :order, inverse_of: :order_items
  belongs_to :product

  default_scope { order(:priority) }
  scope :real, -> { joins(:product).where(products: {virtual: false}) }

  #---
  delegate :virtual?, to: :product
  delegate :approved?, to: :order

  #---
  # Define methods to use archived copies of order items if the associated
  # order is approved, otherwise go through the associations.
  %w[product_code product_customer_code product_title product_subtitle].each do |method|
    association, association_method = method.split('_', 2)
    define_method(method.to_sym) do
      approved? ? self[method] : send(association).send(association_method)
    end
  end

  # Reveal price and components when the order allows it.
  def reveal_price?
    order.reveal_prices?
  end
  def reveal_components?
    order.reveal_components? && product.relationships.any?
  end

  def subtotal
    amount * (price || 0)
  end

  def adjustment_total
    adjustments.map(&:amount).sum
  end

  def archive!
    update(
      product_code: product.code,
      product_customer_code: product.customer_code,
      product_title: product.title,
      product_subtitle: product.subtitle
    )
  end

  def to_s
    product.title
  end
end
