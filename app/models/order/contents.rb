class Order < ActiveRecord::Base

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items

  # The inventory this order ships from by default.
  # If nil, the store doesn't keep stock.
  belongs_to :inventory

  # Inserts amount of product to this order in the context of given
  # group. Options may include a parent item for grouping the order items,
  # and a specific lot code.
  def insert(product, amount, group, options = {})
    return nil if product.nil?
    if product.bundle?
      insert_components(product, amount, group, options.merge(
        parent_item: options[:parent_item]
      ))
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
    price = pricing.for_order(product)
    label = product.best_promoted_item(group).try(:description)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).where(
      product: product,
      parent_item: options[:parent_item],
      lot_code: options[:lot_code],
      additional_info: options[:additional_info]
    ).first_or_create!
    order_item.update!(
      amount: order_item.amount + amount,
      price: price.amount,
      tax_rate: price.tax_rate,
      price_includes_tax: price.tax_included,
      label: label || ''
    )
    if options[:separate_components]
      insert_components(product, amount, group, parent_item: order_item)
    end
    order_item
  end

  # Sets the amount of an existing order item, or inserts the item as new
  # if it doesn't exist. Amounts less than zero delete the item.
  def set_amount(product, amount, group, options = {})
    return nil if product.nil?
    if amount > 0
      order_item = order_items.find_by(product: product) || insert_single(product, amount, group)
      order_item.update(amount: amount)
    else
      order_items.where(product: product).destroy_all
    end
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
    order_items.real.empty?
  end

  def size
    real_items = order_items.real.sum(:amount)
    real_items > 0 ? real_items : nil
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

  # Triggers a recalculate if the order has gone stale,
  # potentionally having out of date promotions applied on it.
  def refresh!
    recalculate! if updated_at < 5.minutes.ago
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
      transaction do
        adjustments.destroy_all
        order_items.each { |order_item| order_item.adjustments.destroy_all }

        source.promotions.active.each do |promotion|
          promotion.apply!(self)
        end
        activated_promotions.live.each do |promotion|
          promotion.apply!(self)
        end
      end
    end

    # Creates the initial transfer containing the tangible order items,
    # associated with the initial shipment, which may already exist.
    # Does nothing if the order has no associated inventory or doesn't
    # require shipping anything.
    def create_initial_transfer!
      shipping_method = store.shipping_methods.active.first
      return nil unless shipping_method.present? && inventory.present? && requires_shipping?
      shipment = shipments.create_with(
        shipping_method: shipping_method
      ).first_or_create!
      shipment.load!
    end
end
