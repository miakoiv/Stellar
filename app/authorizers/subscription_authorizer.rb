class SubscriptionAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    opts[:at].active_subscription.nil? &&
      (user.has_cached_role?(:superuser, opts[:at]) ||
      user.has_cached_role?(:store_admin, opts[:at]))
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end

  def updatable_by?(user, opts)
    user == resource.customer && resource.active?
  end

  def deletable_by?(user, opts)
    resource.active? &&
      (user.has_cached_role?(:superuser, opts[:at]) ||
      user.has_cached_role?(:store_admin, opts[:at]))
  end
end
