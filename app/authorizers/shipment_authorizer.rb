#encoding: utf-8

class ShipmentAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    order = opts[:for]
    user.has_cached_role?(:order_manage, opts[:at]) &&
    order.complete? &&
      !(order.concluded? || order.cancelled? || order.has_pending_shipment? || order.fully_shipped?)
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:order_review, opts[:at]) ||
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end
end
