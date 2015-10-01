#encoding: utf-8

class PromotionAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.is_promotion_editor?
  end

  def self.readable_by?(user)
    user.is_promotion_editor?
  end

  def self.updatable_by?(user)
    user.is_promotion_editor?
  end

  def self.deletable_by?(user)
    user.is_promotion_editor?
  end

end
