#encoding: utf-8

class UserAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.is_user_manager?
  end

  def self.readable_by?(user)
    user.is_user_manager?
  end

  def self.deletable_by?(user)
    false
  end

  def updatable_by?(user)
    user.is_user_manager? || user == current_user
  end
end
