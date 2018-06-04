#encoding: utf-8

class ActivityAuthorizer < ApplicationAuthorizer

  def self.readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end
end
