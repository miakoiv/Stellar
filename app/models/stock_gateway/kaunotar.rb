module StockGateway

  class Kaunotar
    extend ActiveModel::Naming
    include HTTParty
    base_uri Rails.configuration.x.kaunotar.api_uri
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    THRESHOLD = 5

    def initialize(store)
      @store = store
      @client_token = @store.stock_gateway_token
    end

    # Queries the API for information on all products.
    def products
      begin
        response = self.class.get("/products",
          headers: headers,
          timeout: 10
        ).parsed_response
        response.map { |item|
          {
            code: item['barcode2'].presence || item['barcode'],
            customer_code: item['id'].to_s,
            title: item['descriptions'][0]['name'],
            retail_price: Money.new(item['sales_price_cents']),
            online: item['stock_sales'].to_i >= THRESHOLD,
            updated_at: item['updated_at']
          }
        }
      rescue => e
        return []
      end
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
        quantity = response['stock_sales'].to_i - THRESHOLD
        return quantity < 0 ? 0 : quantity
      rescue => e
        return 0
      end
    end

    # Sends an API call to report a sale based on `order` and its contents.
    # Provide `return_url` to view the order from the external platform.
    # Returns true if successful, false otherwise.
    def sale(order, return_url)
      begin
        response = self.class.post("/stock_changes",
          headers: headers,
          body: sale_request(order, return_url).to_json
        ).parsed_response
        return true
      rescue => e
        Rails.logger.error e.message
        return false
      end
    end

    private
      def headers
        {'X-USER-TOKEN' => @client_token}
      end

      def sale_request(order, return_url)
        {
          note: "External order #{order.number}",
          url: return_url,
          item_list: order.order_items.real.map { |item|
            {
              product_id: item.product.customer_code.presence || item.product.code,
              quantity: -item.amount
            }
          }
        }
      end
  end
end
