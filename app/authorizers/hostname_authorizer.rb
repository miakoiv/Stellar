#encoding: utf-8

class HostnameAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin) && resource == user.store
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin) && resource == user.store
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin) && resource == user.store
  end
end
