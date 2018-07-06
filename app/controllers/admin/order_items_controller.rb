#encoding: utf-8

class Admin::OrderItemsController < ApplicationController

  before_action :authenticate_user!

  # No layout, this controller never renders HTML.

  # POST /admin/orders/1/order_items
  # Use Order#insert to create order items correctly.
  def create
    @order = current_store.orders.find(params[:order_id])
    @product = if order_item_params[:customer_code].present?
      current_store.products.live.find_by(customer_code: order_item_params[:customer_code])
    else
      current_store.products.live.find_by(id: order_item_params[:product_id])
    end
    amount = order_item_params[:amount].to_i
    options = {lot_code: concatenated_lot_code}
    respond_to do |format|
      if order_item = @order.insert(@product, amount, @order.source, options)
        track order_item, @order
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
        track @order_item, @order
        @order_item.reload
        @order.recalculate!
      end

      format.js
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
    def order_item_params
      params.require(:order_item).permit(
        :product_id, :amount, :lot_code, :serial,
        :price, :customer_code
      )
    end

    # Lot codes and serials are joined by hyphen if both are present,
    # either one alone is used as the lot code.
    def concatenated_lot_code
      [:lot_code, :serial].map { |k| order_item_params[k].presence }
        .compact.join('-')
    end
end
