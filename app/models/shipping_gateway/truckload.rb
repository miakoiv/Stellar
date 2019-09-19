#
# Shipping gateway for deliveries that are priced by distance, calculated from
# the store shipping origin to the shipping address.
#
module ShippingGateway
  class Truckload
    include ActiveModel::Model

    attr_accessor :order, :shipment, :user, :data

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
      raise ShippingGatewayError, 'Order not specified' if order.nil?
      @store = order.store
      raise ShippingGatewayError, 'Shipping origin not set' if @store.shipping_origin.blank?
      @distance_api = ShippingGateway::Connector::GoogleDistanceMatrix.new
    end

    def prepare_interface_data(params = {})
      origin = @store.shipping_origin
      destination = distance_lookup(origin, I18n.locale)
      {
        origin: origin,
        destination: destination
      }
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
        destinations: [order.shipping_address.address1, order.shipping_address.address2, order.shipping_address.city].join(', ')
      }
      response = @distance_api.lookup(query).parsed_response
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
