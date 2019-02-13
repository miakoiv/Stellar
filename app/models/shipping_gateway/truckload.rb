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

    attr_accessor :order, :shipment, :user

    def self.requires_maps?
      true
    end

    def self.fixed_cost?
      false
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
      @truckload_connector = TruckloadConnector.new
    end

    def calculated_cost(base_price, metadata)
      kilometers = (metadata['distance']['value'].to_f / 1000).round
      base_price * kilometers
    end

    # Performs a distance matrix lookup from given origin to
    # the shipping address of the order. If successful, returns
    # the first element.
    def distance_lookup(origin, locale)
      query = {
        key: order.store.maps_api_key,
        language: locale,
        origins: origin,
        destinations: [order.shipping_address, order.shipping_city].join(', ')
      }
      response = @truckload_connector.lookup(query).parsed_response
      if response['status'] == 'OK'
        response['rows'][0]['elements'][0]
      else
        nil
      end
    end

    def send_shipment
      return [true, nil, nil]
    end

    def to_partial_path
      'shipping_gateway/truckload'
    end
  end
end
