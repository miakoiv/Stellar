#encoding: utf-8

class Admin::InventoryItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_inventory_item, only: [:show, :edit]

  layout 'admin'

  # GET /admin/inventory_items
  # GET /admin/inventory_items.json
  def index
    authorize_action_for InventoryItem, at: current_store
    @query = saved_search_query('inventory_item', 'admin_inventory_item_search')
    @search = InventoryItemSearch.new(search_params)
    @inventory_items = @search.results.page(params[:page])
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
  def edit
    authorize_action_for @inventory_item, at: current_store
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

    # Restrict searching to inventories in current store.
    def search_params
      @query.merge(
        store_id: current_store.id
      )
    end
end
