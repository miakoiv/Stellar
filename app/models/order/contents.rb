class Order < ActiveRecord::Base

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items

  # Inserts amount of product to this order in the context of given
  # parent item. Bundles are inserted as components right away.
  def insert(product, amount, group = nil, parent_item = nil)
    if product.bundle?
      insert_components(product, amount, group, parent_item)
    else
      insert_single(product, amount, group, parent_item, product.composite?)
    end
  end

  # Inserts the component products of given product to this order as
  # subitems of the given parent item.
  def insert_components(product, amount, group, parent_item)
    product.component_entries.each do |entry|
      insert(entry.component, amount * entry.quantity, group, parent_item)
    end
  end

  # Inserts a single product to this order, optionally with separate components.
  # Pricing is according to order source group if not specified.
  def insert_single(product, amount, group, parent_item, separate_components)
    pricing = Appraiser::Product.new(group || source)
    final_price = pricing.for_order(product)
    label = product.best_promoted_item(group).try(:description)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(product: product, parent_item: parent_item)
    order_item.update!(
      amount: order_item.amount + amount,
      price: final_price.amount,
      tax_rate: final_price.tax_rate,
      price_includes_tax: final_price.tax_included,
      label: label || ''
    )
    if separate_components
      insert_components(product, amount, group, order_item)
    end
    order_item
  end

  # Copies the contents of this order to another order by inserting
  # the top level real items. Pricing is according to the source group
  # of the target order.
  def copy_items_to(another_order)
    transaction do
      order_items.top_level.real.each do |item|
        another_order.insert(item.product, item.amount, another_order.source)
      end
    end
  end

  # An order is empty when it's empty of real products.
  def empty?
    products.real.empty?
  end

  # An order is checkoutable when all its real items can be
  # satisfied from given inventory.
  def checkoutable?(inventory)
    order_items.real.each do |item|
      return false unless item.satisfied?(inventory)
    end
    true
  end

  # Order requiring shipping is determined by its contents.
  # A single item that requires shipping will demand shipping
  # for the whole order.
  def requires_shipping?
    order_items.tangible.any?
  end

  # Recalculates things that may take some heavy lifting.
  # This should be called when the contents of the order have changed.
  def recalculate!
    apply_promotions!
    reload
  end

  # Consumes stock for the order contents.
  def consume_stock!(inventory)
    transaction do
      order_items.each do |item|
        item.product.consume!(inventory, item.amount, self)
      end
    end
  end

  # Forwards this order as another order by replacing its items with
  # items from this order, and copying some relevant info over.
  def forward_to(another_order)
    another_order.order_items.destroy_all
    copy_items_to(another_order)
    another_order.update(
      shipping_at: shipping_at,
      installation_at: installation_at,
      company_name: company_name,
      contact_person: contact_person,
      contact_email: contact_email,
      contact_phone: contact_phone,
      has_billing_address: has_billing_address,
      billing_address: billing_address,
      billing_postalcode: billing_postalcode,
      billing_city: billing_city,
      billing_country: billing_country,
      shipping_address: shipping_address,
      shipping_postalcode: shipping_postalcode,
      shipping_city: shipping_city,
      shipping_country: shipping_country,
      notes: notes
    )
  end

  # Coalesces items in this order into a hash by product vendor.
  def items_by_vendor
    order_items.joins(product: :vendor).group_by { |item| item.product.vendor }
  end

  # Order lead time is based on its back ordered items.
  def lead_time_days(inventory)
    order_items.reject { |item|
      item.product.available?(inventory, item.amount)
    }.map { |item|
      item.product.lead_time_days
    }.compact.max || 0
  end

  private
    # Applies active promotions on the order, first removing all existing
    # adjustments from the order and its items.
    def apply_promotions!
      adjustments.destroy_all
      order_items.each { |order_item| order_item.adjustments.destroy_all }

      source.promotions.live.each do |promotion|
        promotion.apply!(self)
      end
    end
end
