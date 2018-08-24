#encoding: utf-8

class InventoryCheckAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:inventory_manage, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:inventory_manage, opts[:at])
  end

  def updatable_by?(user, opts)
    return false if resource.complete?
    user.has_cached_role?(:inventory_manage, opts[:at])
  end

  def deletable_by?(user, opts)
    return false if resource.complete?
    user.has_cached_role?(:inventory_manage, opts[:at])
  end
end
