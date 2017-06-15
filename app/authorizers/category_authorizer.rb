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

  def deletable_by?(user)
    return false if resource.children_count > 0
    user.has_cached_role?(:category_editor)
  end
end
