#encoding: utf-8

module ShippingGateway

  class SmartPostPickupConnector
    include HTTParty
    base_uri 'https://ohjelmat.posti.fi/pup/v1/'
    logger Rails.logger

    def lookup(query)
      self.class.get '/pickuppoints', query: query
    end
  end

  class SmartPost
    include ActiveModel::Model

    attr_accessor :order

    def self.requires_maps?
      true
    end

    def self.fixed_cost?
      true
    end

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @pickup_connector = SmartPostPickupConnector.new
    end

    def calculated_cost(base_price, metadata)
      base_price
    end

    # Performs a lookup of SmartPost pickup locations by given zip code.
    # The post office code servicing the zip area is looked up first,
    # using its locations to look for the nearest five locations around it.
    # Returns a tuple of both results.
    def smartpost_lookup(zipcode)
      postcode = @pickup_connector.lookup(zipcode: zipcode).parsed_response[0]
      return [nil, nil] if postcode.nil?
      query = {
        type: 'smartpost',
        longitude: postcode['MapLongitude'],
        latitude: postcode['MapLatitude'],
        top: 5
      }
      locations = @pickup_connector.lookup(query).parsed_response
      return [postcode, locations]
    end

    def to_partial_path
      'shipping_gateway/smart_post'
    end
  end
end
