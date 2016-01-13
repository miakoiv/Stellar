#encoding: utf-8

class OrderItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable
  monetize :price_cents, allow_nil: true,
    numericality: {
      greater_than_or_equal_to: 0
    }
  monetize :subtotal_cents
  monetize :adjustment_total_cents

  #---
  belongs_to :order, inverse_of: :order_items, touch: true
  belongs_to :product

  default_scope { order(:priority) }
  scope :live, -> { joins(:product).merge(Product.live) }
  scope :undead, -> { joins(:product).merge(Product.undead) }
  scope :real, -> { joins(:product).merge(Product.real) }
  scope :virtual, -> { joins(:product).merge(Product.virtual) }

  #---
  delegate :live?, :undead?, :real?, :virtual?, to: :product
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

  def subtotal_cents
    amount * (price_cents || 0)
  end

  def adjustment_total_cents
    adjustments.sum(:amount_cents)
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
