#encoding: utf-8

class Shipment < ActiveRecord::Base

  belongs_to :order
  belongs_to :shipping_method

  default_scope { order(created_at: :desc) }
  scope :pending, -> { where(shipped_at: nil) }

  #---
  def self.available_gateways
    %w{CustomerPickup Letter SmartPost}
  end

  #---
  def shipping_gateway
    "ShippingGateway::#{shipping_method.shipping_gateway}".constantize
  end
end
