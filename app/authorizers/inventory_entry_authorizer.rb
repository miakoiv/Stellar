#encoding: utf-8

class InventoryEntryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:inventory_manage, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:inventory_manage, opts[:at])
  end

  def self.updatable_by?(user, opts)
    false
  end

  def self.deletable_by?(user, opts)
    false
  end
end
