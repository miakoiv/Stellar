#encoding: utf-8

class PageAuthorizer < ApplicationAuthorizer

  def self.default(able, user)
    user.has_cached_role?(:page_editor)
  end

  def updatable_by?(user)
    if resource_route?
      user.has_cached_role?(:superuser) || user.has_cached_role?(:store_admin)
    else
      user.has_cached_role?(:page_editor)
    end
  end

  def deletable_by?(user)
    if resource_route?
      user.has_cached_role?(:superuser) || user.has_cached_role?(:store_admin)
    else
      user.has_cached_role?(:page_editor)
    end
  end
end
