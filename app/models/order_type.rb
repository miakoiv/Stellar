#encoding: utf-8

class OrderType < ActiveRecord::Base

  belongs_to :store
  has_many :orders

  scope :has_shipping, -> { where(has_shipping: true) }

  # Scopes for outgoing and incoming order types based on given user's group.
  scope :outgoing_for, -> (user) { where(source_group: User.groups[user.group]) }
  scope :incoming_for, -> (user) { where(destination_group: User.groups[user.group]) }

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

  def to_s
    name
  end
end
