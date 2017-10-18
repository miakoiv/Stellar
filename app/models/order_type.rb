#encoding: utf-8

class OrderType < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # This is User.levels transposed for convenience, since order type
  # source level and destination level attributes use the same values,
  # but it's not possible to declare multiple identical enum sets.
  LEVELS = {
    -1 => 'guest',
     0 => 'customer',
     1 => 'reseller',
     2 => 'manufacturer',
     3 => 'vendor'
  }

  #---
  belongs_to :store

  # Source and destination reference groups to define the workflow
  # for orders of this type.
  belongs_to :source, class_name: 'Group'
  belongs_to :destination, class_name: 'Group'

  # Orders are destroyed along with their order type, but see below.
  # Order types should never be destroyed if completed orders exist.
  has_many :orders, dependent: :destroy

  scope :has_shipping, -> { where(has_shipping: true) }

  # Scopes for outgoing and incoming order types based on given user's level.
  scope :outgoing_for, -> (user) { where(source_level: User.levels[user.level]) }
  scope :incoming_for, -> (user) { where(destination_level: User.levels[user.level]) }
  scope :available_for, -> (user) { where(
      arel_table[:source_level].eq(User.levels[user.level])
      .or(arel_table[:destination_level].eq(User.levels[user.level]))
    )
  }

  #---
  def outgoing_for?(user)
    source_level == User.levels[user.level]
  end

  def incoming_for?(user)
    destination_level == User.levels[user.level]
  end

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
