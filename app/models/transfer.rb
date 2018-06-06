#encoding: utf-8

class Transfer < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable

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

  # Loads the given order items into the transfer. To keep track of
  # inventory during the load, matching inventory items are preloaded
  # and updated by each #load_item! call.
  def load!(order_items)
    transaction do
      products = order_items.map(&:product)
      stock = source.inventory_items.online.for(products)
      order_items.each do |order_item|
        load_item!(order_item, stock)
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
    "%s %s ➡ %s" % [note, source, destination]
  end

  private
    # Loads a single order item from given stock into the transfer
    # as one or more transfer items. Updates the stock accordingly.
    def load_item!(order_item, stock)
      stock_items = stock.select { |item| item.product == order_item.product }
      return false if stock_items.none?

      # Ordering by lot code selects inventory item by that code.
      if order_item.lot_code.present? &&
        item = stock_items.find { |item| order_item.lot_code == item.code }

        item.reserved += order_item.amount
        return create_item_from(order_item, order_item.lot_code, item.expires_at)
      end

      amount = order_item.amount_pending
      stock_items.each do |item|
        all = item.available
        next if all <= 0

        if amount <= all
          # This inventory item satisfies the amount, we're done.
          item.reserved += amount
          return create_item_from(order_item, item.code, item.expires_at, amount)
        else
          # Load all of this item and continue with the remaining amount.
          item.reserved += all
          create_item_from(order_item, item.code, item.expires_at, all)
          amount -= all
        end
      end
    end
end
