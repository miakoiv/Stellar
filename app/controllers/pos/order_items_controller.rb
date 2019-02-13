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
    amount = order_item_params[:amount].to_i
    options = {lot_code: order_item_params[:lot_code]}
    respond_to do |format|
      if @order_item = @order.insert(@product, amount, @order.source, options)
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
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order

    if @order_item.destroy
      @order.recalculate!
    end
  end

  private
    def set_order_types
      @order = shopping_cart
      @order_types = @order.available_order_types
    end

    def order_item_params
      params.require(:order_item).permit(
        :product_id, :amount, :lot_code
      )
    end
end
