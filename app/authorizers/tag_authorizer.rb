#encoding: utf-8

class TagAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def updatable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:category_editor, opts[:at])
  end
end
