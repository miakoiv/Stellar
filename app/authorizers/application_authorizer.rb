# Other authorizers should subclass this one

class ApplicationAuthorizer < Authority::Authorizer

  # Any class method from Authority::Authorizer that isn't overridden
  # will call its authorizer's default method.
  #
  # @param [Symbol] adjective; example: `:creatable`
  # @param [Object] user - whatever represents the current user in your app
  # @return [Boolean]
  def self.default(adjective, user, opts = {})
    # 'Whitelist' strategy for security: anything not explicitly allowed is
    # considered forbidden.
    false
  end

  # General authorization to initiate orders
  # as a member of the group specified in opts.
  def self.authorizes_to_order?(user, opts = {})
    group = opts[:as]
    group.present? && group.ordering_allowed?
  end
end
