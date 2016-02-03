#encoding: utf-8

class StoreAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def readable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin) && resource == user.store
  end

  def updatable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin) && resource == user.store
  end

end
