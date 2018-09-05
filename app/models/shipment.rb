#encoding: utf-8

class Shipment < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  belongs_to :order
  belongs_to :shipping_method, required: true
  delegate :shipping_cost_product, :free_shipping_from, to: :shipping_method

  # Shipments refer to a transfer to handle the stock changes.
  has_one :transfer, -> { where(return: false) }

  # If the shipment is returned, another transfer is needed.
  has_one :return_transfer, -> { where(return: true) }, class_name: 'Transfer'

  #---
  PACKAGE_TYPES = %w{PC PU ZPF ZPE ZPT CG ZPX PM TB TC TU LTK KA VA}.freeze

  default_scope { order(created_at: :desc) }
  scope :shipped, -> { where.not(shipped_at: nil) }
  scope :pending, -> { where(shipped_at: nil, cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :active, -> { where(cancelled_at: nil) }

  #---
  with_options on: :update, if: :requires_dimensions?,
    allow_nil: false, numericality: {
    only_integer: true,
    greater_than: 0
  } do |shipment|
    shipment.validates :mass
    shipment.validates :dimension_u
    shipment.validates :dimension_v
    shipment.validates :dimension_w
  end

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

  def self.package_type_options
    PACKAGE_TYPES
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

  # Cancels the shipment and returns it if it was already shipped.
  # Pending shipments are destroyed along with their transfer.
  def cancel!
    if transfer.present? && transfer.complete?
      return!
      update cancelled_at: Time.current
    else
      transfer.destroy! if transfer.present?
      destroy!
    end
  end

  # Returns the shipment by creating and running a return transfer
  # with the items found in the original transfer, using the original
  # source as destination.
  def return!
    self.return_transfer = create_return_transfer(
      store: transfer.store,
      destination: transfer.source
    )
    return_transfer.duplicate_items_from(transfer.transfer_items)
    return_transfer.complete!
  end

  def shipped?
    shipped_at.present?
  end

  def pending?
    !shipped? && !cancelled?
  end

  def cancelled?
    cancelled_at.present?
  end

  def active?
    !cancelled?
  end

  def returned?
    cancelled? && return_transfer.present?
  end

  def requires_dimensions?
    shipping_gateway.requires_dimensions?
  end

  def has_label?
    shipping_gateway.generates_labels?
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

  # Shipment weight as APIs call it, in kilograms.
  def weight
    return nil if mass.nil?
    mass / 1000.0
  end

  # Volume in square metres from dimensions in mm.
  def volume
    return nil if dimension_u.nil? || dimension_v.nil? || dimension_w.nil?
    (dimension_u * dimension_v * dimension_w) / 1_000_000_000.0
  end

  def parsed_metadata
    return {} if metadata.blank?
    JSON.parse(metadata) rescue eval(metadata)
  end

  def shipping_gateway
    shipping_method.shipping_gateway_class
  end

  def appearance
    return 'default muted' if cancelled?
    shipped? ? 'default' : 'primary'
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
