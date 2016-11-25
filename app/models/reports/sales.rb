module Reports

  class Sales

    attr_reader :search, :by_product, :by_date, :total_items, :total_value

    # Supplied params are used to initialize a Searchlight::Search object,
    # which can be accessed through the search attribute.
    def initialize(params)
      @search = OrderItemSearch.new(params)
      items = @search.results
      @by_product = items.group_by(&:product)
      @by_date = items.group_by(&:report_date)
      @total_items = items.pluck(:amount).sum
      @total_value = items.map(&:subtotal_sans_tax).compact.sum
    end

    def chart_data
      data = daily_sales
      {
        datasets: [
          {
            label: I18n.t('admin.reports.sales.chart.daily'),
            data: daily_sales,
            cubicInterpolationMode: 'monotone'
          }
        ]
      }
    end

    private
      def daily_sales
        @by_date.map do |date, items|
          {
            x: date,
            y: items.map(&:subtotal_sans_tax).compact.sum.amount
          }
        end
      end
  end
end
