class Product < ApplicationRecord

  has_many :inventory_items, dependent: :destroy

  # Stock is not tracked for virtual or internal products,
  # or other products with infinite stock enabled.
  def tracked_stock?
    return false if infinite_stock?
    vanilla? || bundle? || composite? || package?
  end

  # Amount available in given inventory, calculated from product
  # availability and/or minimum component availability, recursively.
  # An optional lot code may be specified to target an inventory item.
  # Returns infinite if inventory is not specified or product stock
  # is not tracked.
  def available(inventory, lot_code)
    return Float::INFINITY if inventory.nil? || !tracked_stock?
    return component_stock(inventory) if bundle?
    return [
      stock(inventory, lot_code),
      component_stock(inventory)
    ].min if composite? || package?
    stock(inventory, lot_code)
  end

  # Available means there's at least given amount on hand.
  # It's not necessary to check further if inventory is not specified
  # or product stock is not tracked.
  def available?(inventory, lot_code, amount = 1)
    return true if inventory.nil? || !tracked_stock?
    available(inventory, lot_code) >= amount
  end

  # Out of stock is the opposite of available.
  def out_of_stock?(inventory, lot_code, amount = 1)
    !available?(inventory, lot_code, amount)
  end

  # But out of stock products may be back orderable.
  def back_orderable?
    lead_time.present?
  end

  # Orderable means in stock or back orderable, but stock may not
  # be enough to satisfy the ordered amount, check #satisfies?
  # as soon as the amount is known.
  def orderable?(inventory, lot_code)
    satisfies?(inventory, lot_code, 1)
  end

  # Check if ordering an amount of product can be satisfied.
  def satisfies?(inventory, lot_code, amount)
    back_orderable? || available?(inventory, lot_code, amount)
  end

  # Lead times that look like integers are parsed as number of days,
  # other non-blank strings are considered to be zero days.
  def lead_time_days
    lead_time.presence && lead_time.to_i
  end

  # Restocks given inventory with amount of this product with given lot code
  # and expiration date.
  def restock!(inventory, lot_code, expires_at, amount)
    item = inventory_items.find_or_initialize_by(
      inventory: inventory,
      code: lot_code,
      expires_at: expires_at
    )
    item.inventory_entries.build(
      recorded_at: Date.today,
      on_hand: amount,
      reserved: 0,
      pending: 0,
      value: item.value || trade_price || 0
    )
    item.save!
  end

  private
    # Stock from given inventory, optionally with a specific lot code,
    # used by #available for calculations.
    def stock(inventory, lot_code)
      if lot_code.present?
        item = inventory.item_by_product_and_code(self, lot_code)
        return item.present? ? item.available : 0
      end
      inventory_items.in(inventory).online.map(&:available).sum
    end

    # Minimum stock of components, used by #available.
    # No inventory item is given here since components can't possibly
    # reside in the same inventory lot as the parent product.
    def component_stock(inventory)
      component_entries.map { |entry| entry.available(inventory) }.min || 0
    end
end
