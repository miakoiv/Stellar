#encoding: utf-8

class Admin::InventoryCheckItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_inventory_check, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/inventory_checks/1/inventory_check_items
  def create
    @inventory_check_item = @inventory_check.inventory_check_items
      .find_or_initialize_by(
        inventory_check_item_params.slice(:product_id, :lot_code)
      )
    @inventory_check_item.amount += inventory_check_item_params[:amount].to_i
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
    @inventory_check_item = InventoryCheckItem.find(params[:id])
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
    @inventory_check_item = InventoryCheckItem.find(params[:id])
    @inventory_check = @inventory_check_item.inventory_check
    track @inventory_check_item, @inventory_check

    @inventory_check_item.destroy
  end

  private
    def set_inventory_check
      @inventory_check = current_store.inventory_checks.find(params[:inventory_check_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_check_item_params
      params.require(:inventory_check_item).permit(
        :product_id, :lot_code, :expires_at, :amount,
        :customer_code, :serial
      )
    end
end
