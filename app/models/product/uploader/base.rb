module Product::Uploader

  class Base

    include ActiveModel::Model

    attr_accessor :store, :file

    def initialize(attributes = {})
      super
      raise ArgumentError if store.nil? || file.nil?
      @inventory = store.inventories.first
      @lot_code = file.original_filename
    end

    # Updates a product from the given row, containing:
    # product_code     : required
    # trade_price:     : anything supported by Monetize.parse
    # retail_price     : same as above
    # inventory_amount : targets the first inventory
    def update_from(row)
      product = store.products.where(code: row[:product_code]).first
      return nil if product.nil?

      begin
        if row[:trade_price].present?
          product.update!(trade_price: row[:trade_price].to_money)
        end
        if row[:retail_price].present?
          product.update!(retail_price: row[:retail_price].to_money)
        end
        if row[:inventory_amount].present?
          product.inventory_items.destroy_all
          amount = row[:inventory_amount].to_i
          amount = 0 if amount < 0
          product.restock!(@inventory, @lot_code, nil, amount)
        end
        return json_response(product)
      rescue StandardError => e
        logger.warn e.message
      end
    end

    def json_response(product)
      product.as_json({
        only: [:code, :title, :subtitle],
        methods: [:formatted_price_string]
      })
    end

    def log_error(product)
      Rails.logger.warn product.errors.messages.map { |a, m| "%s: %s" % [a, *m]}.join('; ')
    end
  end
end
