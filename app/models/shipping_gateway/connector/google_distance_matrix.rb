module ShippingGateway
  module Connector
    class GoogleDistanceMatrix
      include HTTParty
      base_uri 'https://maps.googleapis.com/maps/api/distancematrix/'
      logger Rails.logger

      def lookup(query)
        self.class.get '/json', query: query
      end
    end
  end
end
