class Product < ActiveRecord::Base

  has_many :inventory_items, dependent: :destroy

  # Stock is not tracked for virtual or internal products.
  def tracked_stock?
    vanilla? || bundle? || composite?
  end

  # Minimum availability of components, used by #available.
  def component_availability(inventory)
    component_entries.map { |entry| entry.available(inventory) }.min || 0
  end

  # Amount available in given inventory, calculated from product
  # availability and/or minimum component availability, recursively.
  # Returns infinite if inventory is not specified or product stock
  # is not tracked.
  def available(inventory)
    return Float::INFINITY if inventory.nil? || !tracked_stock?
    if bundle?
      component_availability(inventory)
    elsif composite?
      [availability(inventory), component_availability(inventory)].min
    else
      availability(inventory)
    end
  end

  # Available means there's at least given amount on hand.
  # It's not necessary to check further if inventory is not specified
  # or product stock is not tracked.
  def available?(inventory, amount = 1)
    return true if inventory.nil? || !tracked_stock?
    available(inventory) >= amount
  end

  # Out of stock is the opposite of available.
  def out_of_stock?(inventory)
    !available?(inventory)
  end

  # But out of stock products may be back orderable.
  def back_orderable?
    lead_time.present?
  end

  # Orderable means in stock or back orderable, but stock may not
  # be enough to satisfy the ordered amount, check #satisfies?
  # as soon as the amount is known.
  def orderable?(inventory)
    available?(inventory) || back_orderable?
  end

  # Check if ordering an amount of product can be satisfied.
  def satisfies?(inventory, amount)
    available?(inventory, amount) || back_orderable?
  end

  # Lead times that look like integers are parsed as number of days,
  # other non-blank strings are considered to be zero days.
  def lead_time_days
    lead_time.presence && lead_time.to_i
  end

  # Restocks given inventory with amount of this product with given lot code,
  # at given value. If value is not specified, uses the current value of the
  # targeted inventory item, defaulting to product cost price.
  def restock!(inventory, code, amount, value = nil, recorded_at = nil)
    recorded_at ||= Date.today
    item = inventory_items.find_or_initialize_by(
      inventory: inventory,
      code: code
    )
    item.inventory_entries.build(
      recorded_at: recorded_at,
      on_hand: amount,
      reserved: 0,
      pending: 0,
      value: value || item.value || cost_price || 0
    )
    item.save!
  end

  # Consumes given amount of this product from given inventory, starting from
  # the oldest stock. Multiple inventory items may be affected to satisfy
  # the consumed amount. Returns false if we have insufficient stock available.
  # Immediately returns true if no inventory is specified, or stock is not
  # tracked for this product.
  def consume!(inventory, amount, source = nil)
    return true if inventory.nil? || !tracked_stock?
    return false unless available?(inventory, amount)
    inventory_items.in(inventory).online.each do |item|
      if item.available >= amount
        # This inventory item satisfies the amount, destock and finish.
        item.destock!(amount, source)
        break
      else
        # Continue with remaining amount after destocking all of this item.
        amount -= item.available
        item.destock!(item.available, source)
      end
    end
  end

  private
    # Availability based on the inventory items for this product,
    # used by #available for calculations.
    def availability(inventory)
      inventory_items.in(inventory).online.map(&:available).sum
    end
end
