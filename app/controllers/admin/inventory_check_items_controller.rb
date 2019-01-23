#encoding: utf-8

class Admin::InventoryCheckItemsController < AdminController

  before_action :set_inventory_check, only: [:create]
  before_action :set_inventory_check_item, only: [:update, :destroy, :approve, :discard]

  # POST /admin/inventory_checks/1/inventory_check_items
  def create
    item = InventoryCheckItem.new(inventory_check_item_params)
    @inventory_check_item = @inventory_check.inventory_check_items.merge(item)
    action = @inventory_check_item.new_record? ? :create : :update

    respond_to do |format|
      if @inventory_check_item.save
        track @inventory_check_item, @inventory_check, {action: action}
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/inventory_check_items/1
  def update
    @inventory_check = @inventory_check_item.inventory_check

    respond_to do |format|
      if @inventory_check_item.update(inventory_check_item_params)
        track @inventory_check_item, @inventory_check
        format.js { render :update }
      else
        format.js { render :error }
      end
    end
  end

  # DELETE /admin/inventory_check_items/1
  def destroy
    @inventory_check = @inventory_check_item.inventory_check
    track @inventory_check_item, @inventory_check

    @inventory_check_item.destroy
  end

  # PATCH/PUT /admin/inventory_check_items/1/approve
  def approve
    @inventory_check = @inventory_check_item.inventory_check
    @inventory_check_item.approve!
    track @inventory_check_item, @inventory_check
  end

  # PATCH/PUT /admin/inventory_check_items/1/discard
  def discard
    @inventory_check = @inventory_check_item.inventory_check
    @inventory_check_item.discard!
    track @inventory_check_item, @inventory_check
  end

  private
    def set_inventory_check_item
      @inventory_check_item = InventoryCheckItem.find(params[:id])
    end

    def set_inventory_check
      @inventory_check = current_store.inventory_checks.find(params[:inventory_check_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_check_item_params
      params.require(:inventory_check_item).permit(
        :product_id, :lot_code, :expires_at, :current,
        :customer_code, :serial
      )
    end
end
