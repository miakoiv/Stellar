#encoding: utf-8

class IframeAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:product_editor)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:product_editor)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:product_editor)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:product_editor)
  end

end
