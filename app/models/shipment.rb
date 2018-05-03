#encoding: utf-8

class Shipment < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  belongs_to :order
  belongs_to :shipping_method
  delegate :shipping_cost_product, :free_shipping_from, to: :shipping_method

  # Shipments refer to a transfer to handle the stock changes.
  has_one :transfer

  default_scope { order(created_at: :desc) }
  scope :shipped, -> { where.not(shipped_at: nil) }
  scope :pending, -> { where(shipped_at: nil) }

  #---
  def self.available_gateways
    %w{
      Pakettikauppa::Matkahuolto
      Pakettikauppa::Posti
      Pakettikauppa::DbSchenker
      SmartPost
      CustomerPickup
      Letter
      Truckload
      Vendor
    }
  end

  #---
  # Loads this shipment into the associated transfer,
  # from order items still pending shipping.
  def load!
    transfer = find_or_create_transfer
    transfer.load!(order.items_pending_shipping)
  end

  # Forcibly reloads the shipment to pick up new inventory.
  def reload!
    transfer = find_or_create_transfer
    transfer.transfer_items.destroy_all
    load!
  end

  # Completes the shipment by running its transfer and
  # setting the completion timestamp. Returns false if
  # the associated transfer is not feasible.
  def complete!
    return false unless transfer.feasible?
    transfer.complete!
    update shipped_at: Time.current
  end

  def shipped?
    shipped_at.present?
  end

  def pending?
    !shipped?
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
    shipping_method.shipping_gateway_class
  end

  def to_s
    "#{Shipment.human_attribute_name(:number)} #{id}"
  end

  private
    def find_or_create_transfer
      self.transfer ||= create_transfer(
        store: order.store,
        source: order.inventory
      )
    end
end
