#encoding: utf-8

class Admin::OrderItemsController < ApplicationController

  before_action :authenticate_user!

  # No layout, this controller never renders HTML.

  # POST /admin/orders/1/order_items
  # Use Order#insert to create order items correctly.
  def create
    @order = current_store.orders.find(params[:order_id])
    @product = current_store.products.live.find_by(id: order_item_params[:product_id])
    find_inventory_item(@product) if @product.present?
    amount = order_item_params[:amount].to_i
    options = {inventory_item: @inventory_item}
    respond_to do |format|
      if @order.insert(@product, amount, @order.source, options)
        @order.recalculate!
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/order_items/1
  def update
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    authorize_action_for @order_item, at: current_store

    respond_to do |format|
      if @order_item.update(order_item_params)
        @order_item.reload
        @order.recalculate!
        format.js { render :update }
      else
        format.js { render :rollback }
      end
    end
  end

  # DELETE /admin/order_items/1
  def destroy
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order

    if @order_item.destroy
      @order.recalculate!
    end
  end

  private
    def find_inventory_item(product)
      @inventory_item = product.inventory_items.find_by(id: order_item_params[:inventory_item_id])
    end

    def order_item_params
      params.require(:order_item).permit(
        :product_id, :amount, :inventory_item_id, :price
      )
    end
end
