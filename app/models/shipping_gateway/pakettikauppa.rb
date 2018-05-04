#encoding: utf-8
#
# Implementation of several shipping methods available through
# the Pakettikauppa API, using DB Schenker, Matkahuolto, and Posti
# as service providers. Each shipping method is defined in a subclass
# of ShippingGateway::Pakettikauppa.
# For API docs, see <https://www.pakettikauppa.fi/tekniset-ohjeet/>

module ShippingGateway

  class PakettikauppaConnector
    include HTTParty
    base_uri 'https://apitest.pakettikauppa.fi/'
    logger Rails.logger

    def self.list_shipping_methods(query)
      post '/shipping-methods/list', query: query
    end

    def self.search_pickup_points(query)
      post '/pickup-points/search', query: query
    end

    def self.create_shipment(body)
      headers = {'Content-Type' => 'application/xml'}
      post '/prinetti/create-shipment', headers: headers, body: body
    end
  end

  module Pakettikauppa

    class Base
      include ActiveModel::Model

      attr_accessor :order, :shipment

      def self.fixed_cost?
        true
      end

      def initialize(attributes = {})
        super
        raise ArgumentError if order.nil?
        @api_key = '00000000-0000-0000-0000-000000000000'
        @secret = '1234567890ABCDEF'
        @locale = I18n.locale
      end

      def calculated_cost(base_price, metadata)
        base_price
      end

      def list_shipping_methods
        request = hmac_request(language: @locale)
        response = PakettikauppaConnector.list_shipping_methods(request)
          .parsed_response
      end

      def search_pickup_points(postalcode, provider)
        request = hmac_request(
          postcode: postalcode,
          service_provider: provider
        )
        PakettikauppaConnector.search_pickup_points(request).parsed_response
      end

      def create_shipment
        raise ArgumentError if @shipment.nil?
      end

      private

        def hmac_request(params = {})
          request = params.merge(
            api_key: @api_key,
            timestamp: unix_time
          )
          plaintext = request.sort.map { |_, v| v }.join('&')
          request.merge(hash: sha256(@secret, plaintext))
        end

        def sha256(secret, data)
          OpenSSL::HMAC.hexdigest('sha256', secret, data)
        end

        def unix_time
          Time.now.to_i
        end
    end

    class DbSchenker < Base
      def self.requires_maps?
        true
      end

      def search_pickup_points(postalcode)
        super(postalcode, 'Db Schenker')
      end

      def to_partial_path
        'shipping_gateway/pakettikauppa/db_schenker'
      end
    end

    class Matkahuolto < Base
      def self.requires_maps?
        false
      end

      def to_partial_path
        'shipping_gateway/pakettikauppa/matkahuolto'
      end
    end

    class Posti < Base
    end
  end
end
