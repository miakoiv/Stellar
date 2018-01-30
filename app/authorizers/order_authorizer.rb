#encoding: utf-8

class OrderAuthorizer < ApplicationAuthorizer

  # Class methods are called when authorizing an admin
  # to handle incoming orders or create new orders.
  def self.creatable_by?(user, opts)
    user.has_cached_role?(:order_review, opts[:at]) ||
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:order_review, opts[:at]) ||
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:order_manage, opts[:at])
  end

  # Instance methods are called when authorizing a user
  # to browse their own order history, roles don't apply.
  def readable_by?(user, opts)
    user == resource.user
  end

  def updatable_by?(user, opts)
    user == resource.user && !resource.approved?
  end

  def deletable_by?(user, opts)
    user == resource.user && !resource.approved?
  end
end
