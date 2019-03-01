class Admin::InventoryItemsController < AdminController

  before_action :set_inventory_item, only: [:show, :edit]

  authority_actions query: 'read', refresh: 'read'

  # GET /admin/inventory_items
  # GET /admin/inventory_items.json
  def index
    authorize_action_for InventoryItem, at: current_store
    query = saved_search_query('inventory_item', 'admin_inventory_item_search')
    @search = InventoryItemSearch.new(query.merge(search_constrains))
    results = @search.results.reorder(nil).merge(Product.alphabetical)

    respond_to do |format|
      format.html {
        @inventory_items = results.by_product.page(params[:page])
        @products = current_store.products
          .find((query['product_id'] || []).reject(&:blank?))
      }
      format.csv { send_data(results.by_product.to_csv, filename: "inventory-#{current_store.slug}-#{Date.today}.csv") }
    end
  end

  # GET /admin/inventory_items/query.js
  def query
    authorize_action_for InventoryItem, at: current_store
    @product = current_store.products.find(params[:product_id])
    query = saved_search_query('inventory_item', 'admin_inventory_item_search')
    @search = InventoryItemSearch.new(query.merge(query_params))
    results = @search.results.reorder('inventories.name', 'code')
    @inventory_items = results
  end

  # GET /admin/inventory_items/refresh.js
  def refresh
    @product = current_store.products.find(params[:product_id])
    query = saved_search_query('inventory_item', 'admin_inventory_item_search')
    @search = InventoryItemSearch.new(
      query.merge(query_params).merge('online' => 'false')
    )
    logger.info "Searching with #{@search.inspect}"
    results = @search.results.reorder('inventories.name', 'code')
    @inventory_item = results.reorder(nil).by_product.first
    @inventory_items = results
  end

  # GET /admin/inventory_items/1
  def show
    authorize_action_for @inventory_item, at: current_store
  end

  # GET /admin/inventory_items/new
  def new
    authorize_action_for InventoryItem, at: current_store
    @inventory_item = current_store.inventory_items.build
  end

  # GET /admin/inventory_items/1/edit
  # GET /admin/inventory_items/1/edit.js
  def edit
    authorize_action_for @inventory_item, at: current_store

    respond_to :html, :js
  end

  # POST /admin/inventory_items
  # POST /admin/inventory_items.json
  def create
    authorize_action_for InventoryItem, at: current_store

    # Creating an inventory item updates an existing item with a matching code.
    @inventory_item = InventoryItem.find_or_initialize_by(
      inventory_item_params.slice(:inventory_id, :product_id, :code)
    )
    @inventory_item.assign_attributes(inventory_item_params)

    respond_to do |format|
      if @inventory_item.save
        @product = @inventory_item.product
        track @inventory_item, @product
        format.js
        format.html { redirect_to edit_admin_inventory_item_path(@inventory_item),
          notice: t('.notice', inventory_item: @inventory_item) }
        format.json { render :show, status: :created, location: admin_inventory_item_path(@inventory_item) }
      else
        format.js
        format.html { render :new }
        format.json { render json: @inventory_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_item
      @inventory_item = current_store.inventory_items.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_item_params
      params.require(:inventory_item).permit(
        :inventory_id, :product_id, :code,
        inventory_entries_attributes: [
          :recorded_at, :on_hand, :reserved, :pending, :value, :note
        ]
      )
    end

    def query_params
      params.permit(:product_id).merge(search_constrains)
    end

    # Restrict searching to inventories in current store.
    def search_constrains
      {store_id: current_store.id}
    end
end
