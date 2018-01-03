#encoding: utf-8

module ShippingGateway

  class Vendor
    include ActiveModel::Model

    attr_accessor :order

    def self.requires_maps?
      false
    end

    def self.fixed_cost?
      true
    end

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
    end

    def calculated_cost(base_price, metadata)
      base_price
    end

    def to_partial_path
      'shipping_gateway/vendor'
    end
  end
end
