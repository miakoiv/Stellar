module ShippingGateway
  module Connector
    class Pakettikauppa
      include HTTParty
      base_uri Rails.configuration.x.pakettikauppa.api_uri
      logger Rails.logger

      def initialize(api_key, secret)
        @api_key = api_key
        @secret = secret
      end

      def list_shipping_methods(request)
        self.class.post '/shipping-methods/list', query: hmac_request(request)
      end

      def search_pickup_points(request)
        self.class.post '/pickup-points/search', query: hmac_request(request)
      end

      def create_shipment(request)
        headers = {'Content-Type' => 'application/xml'}
        self.class.post '/prinetti/create-shipment', format: :xml, headers: headers, body: request
      end

      def get_shipping_label(request)
        headers = {'Content-Type' => 'application/xml'}
        self.class.post '/prinetti/get-shipping-label', format: :xml, headers: headers, body: request
      end

      private

      # Parts of the Pakettikauppa API require HMAC authentication.
      # This method takes a request and returns a hashed request.
      def hmac_request(request = {})
        hashed_request = request.merge(
          api_key: @api_key,
          timestamp: Time.now.to_i
        )
        plaintext = hashed_request.sort.map { |_, v| v }.join('&')
        hashed_request.merge(hash: sha256(@secret, plaintext))
      end

      def sha256(secret, data)
        OpenSSL::HMAC.hexdigest('sha256', secret, data)
      end
    end
  end
end
