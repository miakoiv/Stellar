#encoding: utf-8

class CategoryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def deletable_by?(user, opts)
    return false if resource.children_count > 0
    user.has_cached_role?(:category_editor, opts[:at])
  end
end
