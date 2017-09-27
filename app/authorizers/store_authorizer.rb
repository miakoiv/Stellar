#encoding: utf-8

class StoreAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at])
  end

  def readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at]) && resource == opts[:at]
  end

  def updatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at]) && resource == opts[:at]
  end
end
