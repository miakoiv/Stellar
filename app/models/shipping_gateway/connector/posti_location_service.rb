module ShippingGateway
  module Connector
    class PostiLocationService
      include HTTParty
      base_uri 'https://locationservice.posti.com/api/2'
      logger Rails.logger

      def lookup(query)
        self.class.get '/location', query: query
      end
    end
  end
end
