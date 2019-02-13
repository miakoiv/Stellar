class ProductAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:product_editor, opts[:at])
  end

  # Third parties have access to products they are vendors for.
  def readable_by?(user, opts)
    return false unless user.has_cached_role?(:product_editor, opts[:at])
    return true unless user.has_cached_role?(:third_party, opts[:at])
    resource.vendor == user.group(opts[:at])
  end

  def updatable_by?(user, opts)
    return false unless user.has_cached_role?(:product_editor, opts[:at])
    return true unless user.has_cached_role?(:third_party, opts[:at])
    resource.vendor == user.group(opts[:at])
  end
end
