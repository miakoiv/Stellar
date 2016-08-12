#encoding: utf-8

class ProductAuthorizer < ApplicationAuthorizer

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

  # Vendors may only interact with their own products.
  def readable_by?(user)
    user.has_cached_role?(:product_editor) && (!user.vendor? || user.vendor? && resource.vendor == user)
  end

  def updatable_by?(user)
    user.has_cached_role?(:product_editor) && (!user.vendor? || user.vendor? && resource.vendor == user)
  end
end
