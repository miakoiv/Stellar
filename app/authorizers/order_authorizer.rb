#encoding: utf-8

class OrderAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user.is_site_manager?  ||
    user.is_store_manager? ||
    user.is_sales_rep?     ||
    false
  end

  def self.readable_by?(user)
    user.is_site_manager?  ||
    user.is_store_manager? ||
    user.is_site_monitor?  ||
    user.is_sales_rep?     ||
    false
  end

  def self.updatable_by?(user)
    user.is_site_manager?  ||
    user.is_store_manager? ||
    user.is_sales_rep?     ||
    false
  end

  def self.deletable_by?(user)
    user.is_site_manager?  ||
    user.is_store_manager? ||
    user.is_sales_rep?     ||
    false
  end

end
