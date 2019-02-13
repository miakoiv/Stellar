#
# This authorizer only applies to actions on order items made through
# the admin namespace. The non-admin side does not use authorizations.
#
class OrderItemAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:order_review, opts[:at]) ||
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def updatable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at]) && resource.active_transfer_items.empty?
  end

  def deletable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at]) && resource.active_transfer_items.empty?
  end
end
