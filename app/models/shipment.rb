#encoding: utf-8

class Shipment < ActiveRecord::Base

  belongs_to :order
  belongs_to :shipping_method
  delegate :shipping_cost_product, :free_shipping_from, to: :shipping_method

  # Shipments must refer to a transfer to handle the stock changes.
  has_one :transfer

  default_scope { order(created_at: :desc) }
  scope :pending, -> { where(shipped_at: nil) }

  #---
  def self.available_gateways
    %w{CustomerPickup Letter SmartPost Truckload Vendor}
  end

  #---
  def shipped?
    shipped_at.present?
  end

  # Calculates the actual shipment cost based on the shipping cost product
  # and given pricing, adjusted by the gateway using the parsed metadata
  # obtained earlier.
  def cost(pricing)
    return nil if free_shipping?
    return nil if shipping_cost_product.nil?
    base_price = pricing.for_order(shipping_cost_product)
    gateway = shipping_gateway.new(order: order)
    gateway.calculated_cost(base_price, parsed_metadata)
  end

  def free_shipping?
    return false if free_shipping_from.nil?
    total = order.includes_tax? ? order.grand_total_with_tax : order.grand_total_sans_tax
    total >= free_shipping_from
  end

  def parsed_metadata
    return {} if metadata.blank?
    JSON.parse(metadata) rescue eval(metadata)
  end

  def shipping_gateway
    "ShippingGateway::#{shipping_method.shipping_gateway}".constantize
  end

  def to_s
    "#{Shipment.human_attribute_name(:number)} #{id}"
  end
end
