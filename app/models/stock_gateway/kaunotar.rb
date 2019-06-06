module StockGateway

  class Kaunotar
    include HTTParty
    base_uri Rails.configuration.x.kaunotar.api_uri
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    def initialize(store)
      @store = store
      @client_token = @store.stock_gateway_token
    end

    def stock(product)
      id = product.customer_code.presence || product.code
      begin
        response = self.class.get("/products/#{id}",
          headers: headers,
          timeout: 10
        ).parsed_response
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
