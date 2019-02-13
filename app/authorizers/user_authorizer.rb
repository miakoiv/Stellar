class UserAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:user_manager, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:user_manager, opts[:at])
  end

  def deletable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at])
  end

  def updatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:user_manager, opts[:at]) || user == resource
  end
end
