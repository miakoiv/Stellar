class Order < ActiveRecord::Base

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items

  # The inventory this order ships from by default.
  # If nil, the store doesn't keep stock.
  # TODO: shipments should include their own inventory reference to allow
  # shipping orders from multiple inventories.
  belongs_to :inventory

  # Inserts amount of product to this order in the context of given
  # group. Options may include a parent item for grouping the order items,
  # and a specific inventory item reference.
  def insert(product, amount, group, options = {})
    return nil if product.nil?
    if product.bundle?
      insert_components(product, amount, group,
        parent_item: options[:parent_item]
      )
    else
      insert_single(product, amount, group, options.merge(
        separate_components: product.composite?
      ))
    end
  end

  # Inserts the component products of given product to this order.
  # Options may include a parent item only, other references are lost.
  def insert_components(product, amount, group, options = {})
    product.component_entries.each do |entry|
      insert(entry.component, amount * entry.quantity, group, options)
    end
  end

  # Inserts a single product to this order, optionally with separate components.
  def insert_single(product, amount, group, options = {})
    pricing = Appraiser::Product.new(group)
    final_price = pricing.for_order(product)
    label = product.best_promoted_item(group).try(:description)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(
      product: product,
      parent_item: options[:parent_item],
      inventory_item: options[:inventory_item]
    )
    order_item.update!(
      amount: order_item.amount + amount,
      price: final_price.amount,
      tax_rate: final_price.tax_rate,
      price_includes_tax: final_price.tax_included,
      label: label || ''
    )
    if options[:separate_components]
      insert_components(product, amount, group, parent_item: order_item)
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
  # satisfied from the target inventory.
  def checkoutable?
    order_items.real.each do |item|
      return false unless item.satisfied?
    end
    true
  end

  # Order requiring shipping is determined by its contents.
  # A single item that requires shipping will demand shipping
  # for the whole order. Returns nil for not applicable (no items).
  def requires_shipping?
    return nil unless order_items.any?
    order_items.tangible.any?
  end

  # Recalculates things that may take some heavy lifting.
  # This should be called when the contents of the order have changed.
  def recalculate!
    apply_promotions!
    reload
  end

  # Consumes stock for the order contents.
  def consume_stock!
    transaction do
      order_items.each do |item|
        item.product.consume!(inventory, item, item.amount, self)
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
  def lead_time_days
    order_items.reject { |item|
      item.available?
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
