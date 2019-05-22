module StockGateway

  class KaunotarConnector
    include HTTParty
    base_uri Rails.configuration.x.kaunotar.api_uri
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    def self.product(id, headers)
      get "/products/#{id}", headers: headers
    end
  end

  class Kaunotar

    include ActiveModel::Model

    attr_accessor :store

    def initialize(attributes = {})
      super
      raise ArgumentError if store.nil?
      @client_token = store.stock_gateway_token
    end

    def stock(product)
      product_id = product.customer_code.presence || product.code
      begin
        response = KaunotarConnector.product(product_id, headers)
          .parsed_response
        return response['stock_sales'].to_i
      rescue => e
        return 0
      end
    end

    private
      def headers
        {'X-USER-TOKEN' => @client_token}
      end
  end
end
