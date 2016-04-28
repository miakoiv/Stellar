#encoding: utf-8

class OrderAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    false
  end

  def self.readable_by?(user)
    user.has_cached_role?(:order_review) ||
    user.has_cached_role?(:order_manage)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:order_manage)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:order_manage)
  end

  def readable_by?(user)
    user == resource.user
  end

  def updatable_by?(user)
    user == resource.user && !resource.approved?
  end

  def deletable_by?(user)
    user == resource.user && !resource.approved?
  end
end
