#encoding: utf-8
#
# This controller deals with editing and deleting items in the shopping cart.
#
class OrderItemsController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  def current_group
    delegate_group || super
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
          @order_item.reset_subitems!
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
      @order = shopping_cart
      @order_types = @order.available_order_types(current_group)
      @order_item = @order.order_items.find(params[:id])
    end

    def order_item_params
      params.require(:order_item).permit(
        :amount
      )
    end
end
