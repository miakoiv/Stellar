module Reports

  class Inventory

    attr_reader :items, :total_value

    def initialize(store)
      @store = store

      @items = @store.inventory_items.joins(:product).merge(Product.live)
      @total_value = @items.map { |item| item.total_value }.sum
    end
  end
end
