#encoding: utf-8

class OrderType < ActiveRecord::Base

  has_many :orders

  # Orders of this type refer to stock in this particular inventory.
  belongs_to :inventory

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

  def to_s
    name
  end
end
