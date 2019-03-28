module Addressed
  extend ActiveSupport::Concern

  ADDRESS_TYPES = [:billing, :shipping].freeze

  included do
    belongs_to :billing_address, class_name: 'Address', optional: true
    belongs_to :shipping_address, class_name: 'Address', optional: true

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
  end

  # Addressed models have address inheritance if they recognize parents.
  def has_address_inheritance?
    respond_to?(:parent)
  end

  def inherited_billing_address
    billing_address.presence ||
      has_address_inheritance? && parent&.inherited_billing_address
  end

  def inherited_shipping_address
    shipping_address.presence ||
      has_address_inheritance? && parent&.inherited_shipping_address
  end

  def inherited_address(type)
    send("inherited_#{type}_address")
  end

  def update_address(type, address)
    raise ArgumentError unless type.in?(Addressed::ADDRESS_TYPES)
    update("#{type}_address" => address)
  end
end
