#encoding: utf-8

class OrderItemAuthorizer < ApplicationAuthorizer

  def self.updatable_by?(user)
    user.has_cached_role?(:order_editor)
  end
end
