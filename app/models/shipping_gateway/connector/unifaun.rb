module ShippingGateway
  module Connector
    class Unifaun
      include HTTParty
      base_uri Rails.configuration.x.unifaun.api_uri
      logger Rails.logger

      def initialize(api_key, secret)
        @api_key = api_key
        @secret = secret
        self.class.basic_auth(@api_key, @secret)
        self.class.headers 'Authorization' => "Bearer #{@api_key}-#{@secret}"
      end

      def create_shipment(request)
        self.class.post '/shipments', request
      end
    end
  end
end
