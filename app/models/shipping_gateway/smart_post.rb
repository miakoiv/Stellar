module ShippingGateway

  class SmartPostPickupConnector
    include HTTParty
    base_uri 'https://locationservice.posti.com/api/2'
    logger Rails.logger

    def self.lookup(query)
      get '/location', query: query
    end
  end

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

    # Performs a lookup of SmartPost pickup locations by given postal code.
    def smartpost_lookup(postalcode)
      query = {
        types: 'SMARTPOST',
        locationZipCode: postalcode,
        top: 6
      }
      response = SmartPostPickupConnector.lookup(query).parsed_response
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
