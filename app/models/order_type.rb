#encoding: utf-8

class OrderType < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # This is User.groups transposed for convenience, since order type
  # source group and destination group attributes use the same values,
  # but it's not possible to declare multiple identical enum sets.
  GROUPS = {
    -1 => 'guest',
     0 => 'customer',
     1 => 'reseller',
     2 => 'manufacturer',
     3 => 'vendor'
  }

  #---
  belongs_to :store

  # Orders are destroyed along with their order type, but see below.
  # Order types should never be destroyed if completed orders exist.
  has_many :orders, dependent: :destroy

  scope :has_shipping, -> { where(has_shipping: true) }

  # Scopes for outgoing and incoming order types based on given user's group.
  scope :outgoing_for, -> (user) { where(source_group: User.groups[user.group]) }
  scope :incoming_for, -> (user) { where(destination_group: User.groups[user.group]) }
  scope :available_for, -> (user) { where(
      arel_table[:source_group].eq(User.groups[user.group])
      .or(arel_table[:destination_group].eq(User.groups[user.group]))
    )
  }

  #---
  def self.group_options
    GROUPS.map { |enum, name| [User.human_attribute_value(:group, name), enum, data: {appearance: User::GROUP_LABELS[name]}.to_json] }
  end

  #---
  def outgoing_for?(user)
    source_group == User.groups[user.group]
  end

  def incoming_for?(user)
    destination_group == User.groups[user.group]
  end

  def payment_gateway_class
    "PaymentGateway::#{payment_gateway}".constantize
  end

  # Checks if any completed orders refer to this order type, cancelled
  # or not. Used by the authorizer to check against deletion.
  def has_any_orders?
    orders.complete.unscope(where: :cancelled_at).any?
  end

  def source_label
    User.human_attribute_value(:group, GROUPS[source_group])
  end

  def destination_label
    User.human_attribute_value(:group, GROUPS[destination_group])
  end

  def source_appearance
    User::GROUP_LABELS[GROUPS[source_group]]
  end

  def destination_appearance
    User::GROUP_LABELS[GROUPS[destination_group]]
  end

  def to_s
    name
  end
end
