class AddressAuthorizer < ApplicationAuthorizer

  def self.default(able, user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at]) ||
    user.has_cached_role?(:user_manager, opts[:at])
  end
end
