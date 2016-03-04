#encoding: utf-8

class PageAuthorizer < ApplicationAuthorizer

  def self.default(able, user)
    user.has_cached_role?(:page_editor)
  end

  def updatable_by?(user)
    user.has_cached_role?(resource.route? ? :superuser : :page_editor)
  end

  def deletable_by?(user)
    user.has_cached_role?(resource.route? ? :superuser : :page_editor)
  end
end
