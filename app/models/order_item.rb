#encoding: utf-8

class OrderItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable
  include Reorderable
  monetize :price_cents, allow_nil: true,
    numericality: {
      greater_than_or_equal_to: 0
    }
  monetize :subtotal_cents
  monetize :adjustment_total_cents

  #---
  belongs_to :order, inverse_of: :order_items, touch: true, counter_cache: true
  belongs_to :product

  # Order items may have subitems that update with their parent, and are not
  # directly updatable or removable.
  belongs_to :parent_item, class_name: 'OrderItem'
  has_many :subitems, class_name: 'OrderItem', foreign_key: :parent_item_id,
    dependent: :destroy

  default_scope { order(:priority) }
  scope :live, -> { joins(:product).merge(Product.live) }
  scope :undead, -> { joins(:product).merge(Product.undead) }
  scope :real, -> { joins(:product).merge(Product.real) }
  scope :virtual, -> { joins(:product).merge(Product.virtual) }

  #---
  validates :amount, numericality: {integer_only: true, greater_than_or_equal_to: 1, less_than: 1000}

  #---
  delegate :live?, :undead?, :real?, :virtual?, to: :product
  delegate :approved?, :concluded?, to: :order

  #---
  def is_subitem?
    parent_item.present?
  end

  # When an order item is updated, its subitems must be updated to reflect
  # the new amount according to the component entries of the product on
  # this order item.
  def reset_subitems!
    entries = product.component_entries
    subitems.each do |subitem|
      component = entries.find_by(component: subitem.product)
      subitem.update! amount: amount * component.quantity
    end
    reload
  end

  # Define methods to use archived copies of order items if the associated
  # order is concluded, otherwise go through the associations.
  %w[product_code product_customer_code product_title product_subtitle].each do |method|
    association, association_method = method.split('_', 2)
    define_method(method.to_sym) do
      concluded? ? self[method] : send(association).send(association_method)
    end
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
