#encoding: utf-8

class PortalAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:superuser)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:superuser)
  end
end
