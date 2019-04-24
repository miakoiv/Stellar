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
    return false if resource.users.count > 0
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:group_editor, opts[:at])
  end
end
