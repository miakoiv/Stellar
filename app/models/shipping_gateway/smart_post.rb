#
# Simple Posti SmartPost shipping gateway that provides a front end interface
# for the customer to select a pick up point using Posti Location Services.
# There is no back end functionality nor connections to any shipping vendor API.
#
module ShippingGateway
  class SmartPost
    include ActiveModel::Model

    attr_accessor :order, :shipment, :user, :data

    def self.requires_maps?
      true
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
      raise ShippingGatewayError, 'Order not specified' if order.nil?
      @data = {}
      @location_api = ShippingGateway::Connector::PostiLocationService.new
    end

    def prepare_interface_data(params = {})
      postalcode = params[:postalcode] || order.shipping_address.postalcode
      locations = smartpost_lookup(postalcode)
      {
        postalcode: postalcode,
        locations: locations
      }
    end

    def calculated_cost(base_price, metadata)
      base_price
    end

    def smartpost_lookup(postalcode)
      query = {
        types: 'SMARTPOST',
        locationZipCode: postalcode,
        top: 6
      }
      response = @location_api.lookup(query).parsed_response
      response['locations'] or raise ShippingGatewayError, response['message']
    end

    def send_shipment
      return [true, nil, nil]
    end

    def to_partial_path
      'shipping_gateway/smart_post'
    end
  end
end
