#encoding: utf-8

class CustomerAssetAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:asset_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:asset_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:asset_editor, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:asset_editor, opts[:at])
  end
end
