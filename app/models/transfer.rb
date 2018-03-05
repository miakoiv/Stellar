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
  # transferred, given current stock levels.
  def feasible?
    transfer_items.each do |item|
      return false unless item.feasible?
    end
    true
  end

  # Creates transfer items based on given order items.
  def create_items_for(order_items)
    transaction do
      order_items.each do |order_item|
        transfer_items.create(
          product: order_item.product,
          lot_code: order_item.lot_code,
          amount: order_item.amount
        )
      end
    end
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
end
