#encoding: utf-8

class StoreAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.is_site_manager?  ||
    false
  end

  def self.readable_by?(user)
    user.is_site_manager?  ||
    user.is_site_monitor?  ||
    false
  end

  def self.updatable_by?(user)
    user.is_site_manager?  ||
    false
  end

  def self.deletable_by?(user)
    user.is_site_manager?  ||
    false
  end

end
