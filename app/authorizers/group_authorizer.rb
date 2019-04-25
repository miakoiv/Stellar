class GroupAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:group_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:group_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:group_editor, opts[:at])
  end

  def deletable_by?(user, opts)
    return false if resource.children_count > 0
    return false if resource.users.count > 0
    return false if resource.orders_as_billing.any? || resource.orders_as_shipping.any?
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:group_editor, opts[:at])
  end
end
