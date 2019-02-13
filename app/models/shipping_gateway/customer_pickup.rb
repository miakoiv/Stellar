module ShippingGateway

  class CustomerPickup
    include ActiveModel::Model

    attr_accessor :order, :shipment, :user

    def self.requires_maps?
      false
    end

    def self.fixed_cost?
      true
    end

    def self.requires_dimensions?
      false
    end

    def self.generates_labels?
      false
    end

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
    end

    def calculated_cost(base_price, metadata)
      base_price
    end

    def send_shipment
      return [true, nil, nil]
    end

    def to_partial_path
      'shipping_gateway/customer_pickup'
    end
  end
end
