module Reports

  class Purchases

    attr_reader :search, :by_product, :by_date, :total_items, :total_value

    # Supplied params are used to initialize a Searchlight::Search object,
    # which can be accessed through the search attribute.
    def initialize(params)
      @search = OrderItemSearch.new(params)
      items = @search.results.reorder('orders.completed_at')
      @by_product = items.group_by(&:product)
      @by_date = items.group_by(&:report_date)
      @total_items = items.pluck(:amount).sum
      @total_value = items.map(&:subtotal_sans_tax).compact.sum
    end

    def chart_data
      dates, purchases = daily_purchases
      {
        labels: dates,
        datasets: [
          {
            label: I18n.t('admin.reports.purchases.chart.daily'),
            data: purchases
          }
        ]
      }
    end

    private
      def daily_purchases
        return [[], []] unless @by_date.any?
        dates = Range.new(*@by_date.keys.minmax).to_a
        purchases = dates.map do |date|
          items = @by_date[date]
          items ? items.map(&:subtotal_sans_tax).compact.sum.amount : nil
        end
        [dates, purchases]
      end
  end
end
