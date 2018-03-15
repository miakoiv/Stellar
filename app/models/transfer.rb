#encoding: utf-8

class Transfer < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store

  # Transfers happen from source to destination, either of which may be nil
  # for a one-sided transfer (from purchases/orders).
  belongs_to :source, class_name: 'Inventory'
  belongs_to :destination, class_name: 'Inventory'

  # If a shipment is associated, this transfer is for its stock changes.
  belongs_to :shipment

  has_many :transfer_items, dependent: :destroy

  default_scope { order(created_at: :desc) }

  scope :complete, -> { where.not(completed_at: nil) }
  scope :manual, -> { where(shipment_id: nil) }

  #---
  validates :destination_id, exclusion: {
    in: -> (transfer) { [transfer.source_id] },
    message: :same_as_source
  }

  #---
  def complete?
    completed_at.present?
  end

  def incomplete?
    !complete?
  end

  # Completes the transfer by creating inventory entries corresponding to
  # the changes made to the source and destination inventories by the
  # transfer items.
  def complete!
    now = Time.current
    transaction do
      transfer_items.each do |item|
        source.present? && source.destock!(item, now, self)
        destination.present? && destination.restock!(item, now, self)
      end
      update completed_at: now
    end
  end

  # Transfer is considered feasible only if all its items can be
  # transferred, given current stock levels. Immediately returns
  # true if the source is nil, denoting an external source.
  def feasible?
    return true if source.nil?
    transfer_items.each do |item|
      return false unless item.feasible?
    end
    true
  end

  # Loads the given order items into the transfer.
  def load!(order_items)
    transaction do
      order_items.each do |order_item|
        load_item!(order_item)
      end
    end
  end

  # Creates a new transfer item based on given order item, specifying the
  # product, lot code, and amount, if not overridden by arguments.
  def create_item_from(order_item, lot_code = nil, expires_at = nil, amount = nil)
    transfer_items.create(
      order_item: order_item,
      product: order_item.product,
      lot_code: lot_code || order_item.lot_code,
      expires_at: expires_at,
      amount: amount || order_item.amount_pending
    )
  end

  def appearance
    if incomplete?
      return 'danger text-danger' unless feasible?
      'warning text-warning'
    end
  end

  def icon
    if incomplete?
      return 'warning' unless feasible?
      'cog'
    end
  end

  def to_s
    note
  end

  private
    # Loads a single order item into the transfer as one or more
    # transfer items. If the order item specifies a lot code, it will be
    # used for a single transfer item. Otherwise the amount of product is
    # found from the source inventory starting from oldest stock.
    def load_item!(order_item)
      if order_item.lot_code.present? &&
        inventory_item = source.item_by_product_and_code(
          order_item.product,
          order_item.lot_code
        )
        return create_item_from(order_item, order_item.lot_code, inventory_item.expires_at)
      end

      amount = order_item.amount_pending
      source.inventory_items.for(order_item.product).online.each do |item|
        if item.available >= amount
          # This inventory item satisfies the amount, we're done.
          return create_item_from(order_item, item.code, item.expires_at, amount)
        else
          # Load all of this item and continue with the remaining amount.
          create_item_from(order_item, item.code, item.expires_at, item.available)
          amount -= item.available
        end
      end
    end
end
