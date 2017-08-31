#encoding: utf-8

class OrderTypeAuthorizer < ApplicationAuthorizer

  def self.default(able, user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end

  def deletable_by?(user)
    return false if resource.has_any_orders?
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end
end
