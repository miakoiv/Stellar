#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory

  # Inventory items don't reference a product directly,
  # instead there is a `code` attribute that may refer to
  # multiple products under different stores simultaneously.

  default_scope { order(:inventory_id) }

  # Adjustment attribute is calculated on the fly from
  # orders affecting the stock. OrderItem#adjust! calls
  # InventoryItem#adjust! via Store#stock_lookup.
  attr_accessor :adjustment
  def adjust!(amount)
    self.adjustment ||= 0
    self.adjustment += amount
  end

  def total_value
    return nil if amount.nil? || value.nil?
    amount * value
  end

  def shippable?
    inventory.purpose == 'shipping'
  end

  # Inventory item HTML representation methods.
  def title; inventory.name; end
  def klass; inventory.purpose; end
end
