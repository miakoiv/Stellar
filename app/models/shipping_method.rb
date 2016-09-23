#encoding: utf-8

class ShippingMethod < ActiveRecord::Base

  belongs_to :store
  has_many :shipments

  def shipping_gateway_class
    "ShippingGateway::#{shipping_gateway}".constantize
  end

  def to_s
    name
  end
end
