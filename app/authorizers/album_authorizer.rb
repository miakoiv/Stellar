#encoding: utf-8

class AlbumAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.has_cached_role?(:album_editor)
  end

  def self.readable_by?(user)
    user.has_cached_role?(:album_editor)
  end

  def self.updatable_by?(user)
    user.has_cached_role?(:album_editor)
  end

  def self.deletable_by?(user)
    user.has_cached_role?(:album_editor)
  end

end
