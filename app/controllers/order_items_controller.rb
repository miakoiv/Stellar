#encoding: utf-8
#
# Order items have a dualist nature as shopping cart items before they
# are part of a completed order. If the item being updated is part of
# an incomplete order, @is_cart will be set, and permitted parameters
# restricted to amounts only.
# Rendering responses to AJAX requests looks at this variable to render
# appropriate updates to the DOM.
#
class OrderItemsController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Guest users may edit their shopping cart contents.
  before_action :authenticate_user_or_skip!

  before_action :set_order_and_item

  # PATCH/PUT /order_items/1
  def update
    respond_to do |format|
      if @order_item.update(order_item_params)
        if @order_item.amount < 1
          @order_item.destroy
          format.js { render :destroy }
        else
          @order_item.reload
          @order.recalculate!
          format.js { render :update }
        end
      else
        format.js { render :rollback }
      end
    end
  end

  # DELETE /order_items/1
  def destroy
    if @order_item.destroy
      @order.recalculate!
    end
  end

  private
    def set_order_and_item
      @order_item = OrderItem.find(params[:id])
      @order = @order_item.order
      @is_cart = !@order.complete?
    end

    def order_item_params
      permitted = @is_cart ? [:amount] : [:amount, :price]
      params.require(:order_item).permit(*permitted)
    end
end
