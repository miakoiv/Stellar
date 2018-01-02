#encoding: utf-8

module ShippingGateway

  class TruckloadConnector
    include HTTParty
    base_uri 'https://maps.googleapis.com/maps/api/distancematrix/'
    logger Rails.logger

    def lookup(query)
      self.class.get '/json', query: query
    end
  end

  class Truckload
    include ActiveModel::Model

    attr_accessor :order

    def self.requires_maps?
      true
    end

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @truckload_connector = TruckloadConnector.new
    end

    # Performs a distance matrix lookup from given origin to
    # the shipping address of the order. Returns the first row
    # of results as the destination, if any.
    def distance_lookup(origin, locale)
      query = {
        key: order.store.maps_api_key,
        language: locale,
        origins: origin,
        destinations: [order.shipping_address, order.shipping_city].join(', ')
      }
      response = @truckload_connector.lookup(query).parsed_response
      if response['status'] == 'OK'
        return response['rows'][0]['elements'][0]
      else
        return nil
      end
    end

    def to_partial_path
      'shipping_gateway/truckload'
    end
  end
end
