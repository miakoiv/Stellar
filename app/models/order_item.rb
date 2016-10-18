#encoding: utf-8

class OrderItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable
  include Reorderable
  monetize :price_cents, allow_nil: true
  monetize :price_sans_tax_cents, :tax_cents, :price_with_tax_cents, disable_validation: true
  monetize :subtotal_sans_tax_cents, :tax_subtotal_cents, :subtotal_with_tax_cents, disable_validation: true
  monetize :adjustments_sans_tax_cents, :adjustments_with_tax_cents, disable_validation: true

  #---
  belongs_to :order, inverse_of: :order_items, touch: true, counter_cache: true
  belongs_to :product

  # Order items may have subitems that update with their parent, and are not
  # directly updatable or removable.
  belongs_to :parent_item, class_name: 'OrderItem'
  has_many :subitems, class_name: 'OrderItem', foreign_key: :parent_item_id,
    dependent: :destroy

  default_scope { order(:priority) }
  scope :top_level, -> { where(parent_item_id: nil) }
  scope :live, -> { joins(:product).merge(Product.live) }
  scope :undead, -> { joins(:product).merge(Product.undead) }
  scope :real, -> { joins(:product).merge(Product.real) }
  scope :virtual, -> { joins(:product).merge(Product.virtual) }

  #---
  validates :amount, numericality: {integer_only: true, greater_than_or_equal_to: 1, less_than: 1000}

  #---
  delegate :live?, :undead?, :real?, :virtual?, to: :product
  delegate :includes_tax?, :approved?, :concluded?, to: :order

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

  # Price without tax deducts the tax portion if it's included in the attribute.
  def price_sans_tax_cents
    return nil if price_cents.nil?
    if price_includes_tax?
      price_cents - tax_cents
    else
      price_cents
    end
  end

  # Tax is calculated from the price attribute, which may include tax.
  def tax_cents
    return nil if price_cents.nil?
    if price_includes_tax?
      price_cents * tax_rate / (tax_rate + 100)
    else
      price_cents * tax_rate / 100
    end
  end

  # Price with tax adds the tax portion if it wasn't included.
  def price_with_tax_cents
    return nil if price_cents.nil?
    if price_includes_tax?
      price_cents
    else
      price_sans_tax_cents + tax_cents
    end
  end

  def subtotal_sans_tax_cents
    return nil if price_cents.nil?
    amount * price_sans_tax_cents
  end

  def tax_subtotal_cents
    return nil if price_cents.nil?
    amount * tax_cents
  end

  def subtotal_with_tax_cents
    return nil if price_cents.nil?
    amount * price_with_tax_cents
  end

  def adjustments_sans_tax_cents
    adjustments.map(&:amount_sans_tax_cents).sum
  end

  def adjustments_with_tax_cents
    adjustments.map(&:amount_with_tax_cents).sum
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
