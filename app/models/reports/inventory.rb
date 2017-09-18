module Reports

  class Inventory

    COLUMNS = {
      'title' => 'products.title',
      'code' => '(products.code * 1)',
      'on_hand' => 'inventory_items.on_hand',
      'value' => 'inventory_items.value_cents',
      'total_value' => 'total_value_cents'
    }.freeze

    attr_reader :items, :total_value

    def initialize(params)
      @search = InventoryItemSearch.new(params)
      @items = @search.results.reorder(params[:sort])
      @total_value = @items.map { |item| item.total_value }.sum
    end
  end
end
