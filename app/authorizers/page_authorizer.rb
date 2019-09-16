class PageAuthorizer < ApplicationAuthorizer

  def self.default(able, user, opts)
    user.has_cached_role?(:page_editor, opts[:at])
  end

  def updatable_by?(user, opts)
    return false if resource.header? || resource.footer?
    if resource.route?
      user.has_cached_role?(:superuser, opts[:at]) || user.has_cached_role?(:store_admin, opts[:at])
    else
      user.has_cached_role?(:page_editor, opts[:at])
    end
  end

  def deletable_by?(user, opts)
    return false if resource.header? || resource.footer?
    return false if resource.children_count > 0
    if resource.route?
      user.has_cached_role?(:superuser, opts[:at]) || user.has_cached_role?(:store_admin, opts[:at])
    else
      user.has_cached_role?(:page_editor, opts[:at])
    end
  end

  # This method is only needed by StoreController to ensure that
  # the page is either public, or accessible by a group.
  def readable_by?(user, opts)
    groups = resource.groups
    return true if groups.empty? || groups.include?(opts[:for]) ||
      user.has_cached_role?(:superuser, opts[:at]) || user.has_cache_role?(:page_editor, opts[:at])
    false
  end
end
