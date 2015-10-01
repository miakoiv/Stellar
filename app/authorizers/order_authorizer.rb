#encoding: utf-8

class OrderAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    false
  end

  def self.readable_by?(user)
    user.is_order_editor?
  end

  def self.updatable_by?(user)
    user.is_order_editor?
  end

  def self.deletable_by?(user)
    user.is_order_editor?
  end

  def readable_by?(user)
    user == resource.user
  end

  def updatable_by?(user)
    user == resource.user && !resource.approval
  end

  def deletable_by?(user)
    user == resource.user
  end
end
