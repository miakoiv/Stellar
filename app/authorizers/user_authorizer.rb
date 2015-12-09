#encoding: utf-8

class UserAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:user_manager)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:user_manager)
  end

  def self.deletable_by?(user)
    false
  end

  def updatable_by?(user)
    user.has_cached_role?(:user_manager) || user == resource
  end
end
