#encoding: utf-8

class PropertyAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:property_editor)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:property_editor)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:property_editor)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:property_editor)
  end

end
