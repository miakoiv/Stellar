#encoding: utf-8

class AssetEntryAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:asset_editor)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:asset_editor)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:asset_editor)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:asset_editor)
  end

end
