class MessageAuthorizer < ApplicationAuthorizer

  def self.default(able, user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end
end
