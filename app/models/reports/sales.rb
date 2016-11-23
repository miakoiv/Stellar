module Reports

  class Sales

    attr_reader :search, :by_product, :total_items, :total_value

    # Supplied params are used to initialize a Searchlight::Search object,
    # which can be accessed through the search attribute.
    def initialize(params)
      @search = OrderItemSearch.new(params)
      items = @search.results
      @by_product = items.group_by(&:product)
      @total_items = items.pluck(:amount).sum
      @total_value = items.map(&:subtotal_sans_tax).compact.sum
    end
  end
end
