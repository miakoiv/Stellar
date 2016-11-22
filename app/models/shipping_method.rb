#encoding: utf-8

class ShippingMethod < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable

  #---
  belongs_to :store
  has_many :shipments

  # A reference to a page containing pertinent details displayed during
  # checkout as a button opening the page contents in a modal.
  belongs_to :detail_page, class_name: 'Page'

  scope :active, -> { where '(shipping_methods.enabled_at IS NULL OR shipping_methods.enabled_at <= :today) AND (shipping_methods.disabled_at IS NULL OR shipping_methods.disabled_at > :today)', today: Date.current }

  #---
  def active?
    (enabled_at.nil? || !enabled_at.future?) &&
    (disabled_at.nil? || disabled_at.future?)
  end

  def shipping_gateway_class
    "ShippingGateway::#{shipping_gateway}".constantize
  end

  def to_s
    name
  end
end
