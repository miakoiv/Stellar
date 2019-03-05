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
    store = opts[:at]
    return false unless user.has_cached_role?(:product_editor, store)
    return true unless user.has_cached_role?(:third_party, store)
    group = user.group(store)
    group.present? && resource.vendor == group
  end
  alias_method :updatable_by?, :readable_by?
end
