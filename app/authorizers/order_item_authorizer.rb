#encoding: utf-8

class OrderItemAuthorizer < ApplicationAuthorizer

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end
end
