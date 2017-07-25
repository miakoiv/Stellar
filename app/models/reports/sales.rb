module Reports

  class Sales

    attr_reader :search, :by_product, :by_date, :total_items, :total_value, :labels, :dataset

    # Supplied params are used to initialize a Searchlight::Search object,
    # which can be accessed through the search attribute.
    def initialize(params)
      @search = OrderItemSearch.new(params)
      items = @search.results.reorder('orders.completed_at')
      @by_product = items.group_by(&:product)
      @by_date = items.group_by(&:report_date)
      @total_items = items.pluck(:amount).sum
      @total_value = items.map(&:subtotal_sans_tax).compact.sum
      @labels, @dataset = to_chartdata
    end

    private
      def to_chartdata
        return [[], []] unless @by_date.any?
        labels = Range.new(*@by_date.keys.minmax).to_a
        sales = labels.map do |date|
          items = @by_date[date]
          items ? items.map(&:subtotal_sans_tax).compact.sum.amount : nil
        end
        [labels.map(&:to_s), sales.map(&:to_f)]
      end
  end
end
