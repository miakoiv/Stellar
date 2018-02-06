#encoding: utf-8
#
# This is the point-of-sale specific controller for order items.
#
class Pos::OrderItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order_types

  layout 'point_of_sale'

  # POST /pos/orders/1/order_items
  # Use Order#insert to create order items correctly.
  def create
    @product = current_store.products.live.find_by(id: order_item_params[:product_id])
    find_inventory_item_and_entry(@product) if @product.present?
    amount = order_item_params[:amount].to_i
    options = {
      inventory_item: @inventory_item,
      inventory_entry: @inventory_entry
    }
    respond_to do |format|
      if @order_item = @order.insert(@product, amount, current_group, options)
        @order.recalculate!
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /pos/order_items/1
  def update
    @order_item = @order.order_items.find(params[:id])

    respond_to do |format|
      if @order_item.update(order_item_params)
        if @order_item.amount < 1
          @order_item.destroy
          format.js { render :destroy }
        else
          @order_item.reset_subitems!
          @order.recalculate!
          format.js { render :update }
        end
      else
        format.js { render :rollback }
      end
    end
  end

  # DELETE /pos/order_items/1
  def destroy
    @order_item = @order.order_items.find(params[:id])

    if @order_item.destroy
      @order.recalculate!
    end
  end

  private
    def set_order_types
      @order = shopping_cart
      @order_types = @order.available_order_types(current_group)
    end

    def find_inventory_item_and_entry(product)
      @inventory_item = product.inventory_items.find_by(id: order_item_params[:inventory_item_id])
      @inventory_entry = @inventory_item.present? ? @inventory_item.entries.find_by(id: order_item_params[:inventory_entry_id]) : nil
    end

    def order_item_params
      params.require(:order_item).permit(
        :product_id, :amount, :inventory_item_id, :inventory_entry_id
      )
    end
end
