#encoding: utf-8

class CategoryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:category_editor)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:category_editor)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:category_editor)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:category_editor)
  end

end
