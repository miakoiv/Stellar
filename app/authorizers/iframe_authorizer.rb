#encoding: utf-8

class IframeAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end
end
