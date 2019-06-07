module StockGateway

  class Kaunotar
    extend ActiveModel::Naming
    include HTTParty
    base_uri Rails.configuration.x.kaunotar.api_uri
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    def initialize(store)
      @store = store
      @client_token = @store.stock_gateway_token
    end

    # Queries the API for the stock level of `product`.
    # Returns an integer, or 0 if the query fails.
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

    # Sends an API call to report a sale based on `order` and its contents.
    # Returns the argument if successful, nil otherwise.
    def sale(order)
      begin
        response = self.class.post("/orders",
          headers: headers,
          body: sale_request(order)
        ).parsed_response
        return order
      rescue => e
        Rails.logger.error e.message
        return nil
      end
    end

    private
      def headers
        {'X-USER-TOKEN' => @client_token}
      end

      def sale_request(order)
        {
          order_number: order.number,
          timestamp: order.completed_at,
          line_items: order.order_items.real.map { |item|
            {
              product: item.product.customer_code.presence || item.product.code,
              amount: item.amount
            }
          }
        }
      end
  end
end
