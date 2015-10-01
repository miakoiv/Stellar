#encoding: utf-8

class StoreAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.is_superuser?
  end

  def self.readable_by?(user)
    user.is_superuser?
  end

  def self.updatable_by?(user)
    user.is_superuser?
  end

  def self.deletable_by?(user)
    user.is_superuser?
  end

end
