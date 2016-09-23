#encoding: utf-8

module ShippingGateway

  class SmartPostPickupConnector
    include HTTParty
    base_uri 'https://ohjelmat.posti.fi/pup/v1/'
    logger Rails.logger

    # Queries pickup locations by zip code, returns post code information.
    # We are interested in the longitude and latitude.
    def lookup(query)
      self.class.get '/pickuppoints', query: query
    end
  end

  class SmartPost
    include ActiveModel::Model

    attr_accessor :order

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @pickup_connector = SmartPostPickupConnector.new
    end

    # Performs a lookup of SmartPost pickup locations by given zip code.
    # The post office code servicing the zip area is looked up first,
    # using its locations to look for the nearest five locations around it.
    # Returns a tuple of both results.
    def smartpost_lookup(zipcode)
      postcode = @pickup_connector.lookup(zipcode: zipcode).parsed_response[0]
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
