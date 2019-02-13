class PromotionAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, opts)
    user.has_cached_role?(:promotion_editor, opts[:at])
  end

  def self.readable_by?(user, opts)
    user.has_cached_role?(:promotion_editor, opts[:at])
  end

  def self.updatable_by?(user, opts)
    user.has_cached_role?(:promotion_editor, opts[:at])
  end

  def self.deletable_by?(user, opts)
    user.has_cached_role?(:promotion_editor, opts[:at])
  end
end
