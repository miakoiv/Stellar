class Product < ActiveRecord::Base

  has_many :inventory_items, dependent: :destroy

  # Stock is not tracked for virtual or internal products.
  def tracked_stock?
    vanilla? || bundle? || composite?
  end

  # Amount available in given inventory or inventory item, calculated
  # from product availability and/or minimum component availability,
  # recursively. Returns infinite if inventory is not specified or
  # product stock is not tracked.
  def available(inventory, item)
    return Float::INFINITY if inventory.nil? || !tracked_stock?
    return component_stock(inventory) if bundle?
    return [stock(inventory, item), component_stock(inventory)].min if composite?
    stock(inventory, item)
  end

  # Available means there's at least given amount on hand.
  # It's not necessary to check further if inventory is not specified
  # or product stock is not tracked.
  def available?(inventory, item, amount = 1)
    return true if inventory.nil? || !tracked_stock?
    available(inventory, item) >= amount
  end

  # Out of stock is the opposite of available.
  def out_of_stock?(inventory, item, amount = 1)
    !available?(inventory, item, amount)
  end

  # But out of stock products may be back orderable.
  def back_orderable?
    lead_time.present?
  end

  # Orderable means in stock or back orderable, but stock may not
  # be enough to satisfy the ordered amount, check #satisfies?
  # as soon as the amount is known.
  def orderable?(inventory, item)
    satisfies?(inventory, item, 1)
  end

  # Check if ordering an amount of product can be satisfied.
  def satisfies?(inventory, item, amount)
    back_orderable? || available?(inventory, item, amount)
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

  # Consumes given amount of this product from given inventory, either from
  # given inventory item only, or starting from the oldest stock.
  # When no item is specified, multiple inventory items may be used to satisfy
  # the consumed amount. Returns false if we have insufficient stock available.
  # Immediately returns true if no inventory is specified, or stock is not
  # tracked for this product.
  def consume!(inventory, item, amount, source = nil)
    return true if inventory.nil? || !tracked_stock?
    return false unless available?(inventory, item, amount)
    if item.present?
      item.destock!(amount, source)
      return true
    end
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
    # Stock from given inventory, optionally a specific inventory item,
    # used by #available for calculations.
    def stock(inventory, item)
      return item.available if item.present?
      inventory_items.in(inventory).online.map(&:available).sum
    end

    # Minimum stock of components, used by #available.
    # No inventory item is given here since components can't possibly
    # reside in the same inventory lot as the parent product.
    def component_stock(inventory)
      component_entries.map { |entry| entry.available(inventory) }.min || 0
    end
end
