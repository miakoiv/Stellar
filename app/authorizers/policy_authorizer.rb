class PolicyAuthorizer < ApplicationAuthorizer

  def self.readable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at]) ||
    user.has_cached_role?(:store_admin, opts[:at])
  end

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:superuser, opts[:at])
  end

  # Policies remain editable if not mandatory or not accepted.
  def updatable_by?(user, opts)
    return false unless user.has_cached_role?(:superuser, opts[:at])
    !resource.mandatory? || !resource.accepted?
  end

  # Store admins are generally able to accept policies.
  def self.acceptable_by?(user, opts)
    user.has_cached_role?(:store_admin, opts[:at])
  end

  # Store admins may accept policies if pending.
  def acceptable_by?(user, opts)
    return false unless user.has_cached_role?(:store_admin, opts[:at])
    resource.pending?
  end
end
