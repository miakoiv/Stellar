#encoding: utf-8

class OrderType < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store

  # Source and destination reference groups to define the workflow
  # for orders of this type.
  belongs_to :source, class_name: 'Group', inverse_of: :outgoing_order_types
  belongs_to :destination, class_name: 'Group', inverse_of: :incoming_order_types

  # Orders are destroyed along with their order type, but see below.
  # Order types should never be destroyed if completed orders exist.
  has_many :orders, dependent: :destroy

  scope :has_shipping, -> { where(has_shipping: true) }
  scope :available_for, -> (group) {
    where(arel_table[:source_id].eq(group)
      .or(arel_table[:destination_id].eq(group)))
  }

  #---
  def payment_gateway_class
    "PaymentGateway::#{payment_gateway}".constantize
  end

  # Checks if any completed orders refer to this order type, cancelled
  # or not. Used by the authorizer to check against deletion.
  def has_any_orders?
    orders.complete.unscope(where: :cancelled_at).any?
  end

  def to_s
    name
  end
end
