#encoding: utf-8
#
# Implementation of several shipping methods available through
# the Pakettikauppa API, using DB Schenker, Matkahuolto, and Posti
# as service providers. Each shipping method is defined in a subclass
# of ShippingGateway::Pakettikauppa.
# For API docs, see <https://www.pakettikauppa.fi/tekniset-ohjeet/>

module ShippingGateway
  module Pakettikauppa

    class PakettikauppaConnector
      include HTTParty
      base_uri 'https://apitest.pakettikauppa.fi/'
      logger Rails.logger

      def list_shipping_methods(request)
        self.class.post('/shipping-methods/list', query: request)
      end
    end

    class Base

      include ActiveModel::Model

      attr_accessor :order, :shipment

      def initialize(attributes = {})
        super
        raise ArgumentError if order.nil?
        @api_key = '00000000-0000-0000-0000-000000000000'
        @secret = '1234567890ABCDEF'
        @locale = I18n.locale
        @connector = PakettikauppaConnector.new
      end

      def list_shipping_methods
        request = hmac_request(
          api_key: @api_key,
          timestamp: unix_time,
          language: @locale
        )
        response = @connector.list_shipping_methods(request).parsed_response
      end

      private

        def hmac_request(params = {})
          plaintext = params.sort.map { |_, v| v }.join('&')
          params.merge(hash: sha256(@secret, plaintext))
        end

        def sha256(secret, data)
          OpenSSL::HMAC.hexdigest('sha256', secret, data)
        end

        def unix_time
          Time.now.to_i
        end
    end

    class SchenkerNouto < Base
      def to_partial_path
        'shipping_gateway/pakettikauppa/schenker_nouto'
      end
    end

    class MatkahuoltoBussi < Base
      def to_partial_path
        'shipping_gateway/pakettikauppa/matkahuolto_bussi'
      end
    end

    class MatkahuoltoJako < Base
      def to_partial_path
        'shipping_gateway/pakettikauppa/matkahuolto_jako'
      end
    end

    class PostiExpress < Base
      def to_partial_path
        'shipping_gateway/pakettikauppa/posti_express'
      end
    end
  end
end
