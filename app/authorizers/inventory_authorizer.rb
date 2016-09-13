#encoding: utf-8

class InventoryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:inventory_manage)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:inventory_manage)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:inventory_manage)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:inventory_manage)
  end
end
