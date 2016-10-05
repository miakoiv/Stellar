#encoding: utf-8

class TaxCategoryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:superuser) ||
    user.has_cached_role?(:store_admin)
  end
end
