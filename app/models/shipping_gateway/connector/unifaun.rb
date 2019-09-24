module ShippingGateway
  module Connector
    class Unifaun
      include HTTParty
      base_uri Rails.configuration.x.unifaun.api_uri
      headers 'Content-Type' => 'application/json'
      format :json
      logger Rails.logger

      def initialize(api_key, secret)
        @api_key = api_key
        @secret = secret
        self.class.headers 'Authorization' => "Bearer #{@api_key}-#{@secret}"
      end

      def create_shipment(request)
        self.class.post '/shipments', body: request.to_json
      end
    end
  end
end
