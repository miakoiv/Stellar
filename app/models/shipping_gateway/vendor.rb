#encoding: utf-8

module ShippingGateway

  class Vendor
    include ActiveModel::Model

    attr_accessor :order

    def self.requires_maps?
      false
    end

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
    end

    def to_partial_path
      'shipping_gateway/vendor'
    end
  end
end
