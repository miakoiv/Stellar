#encoding: utf-8

class OrderItemsController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Guest users may edit their shopping cart contents.
  before_action :authenticate_user_or_skip!

  # PATCH/PUT /order_items/1
  def update
    @order_item = OrderItem.find(params[:id])
    @order = current_user.shopping_cart(current_store)

    respond_to do |format|
      if @order_item.update(order_item_params)
        if @order_item.amount < 1
          @order_item.destroy
          format.js { render :destroy }
        else
          format.js
        end
      end
    end
  end

  # DELETE /order_items/1
  def destroy
    @order_item = OrderItem.find(params[:id])
    @order = current_user.shopping_cart(current_store)

    respond_to do |format|
      if @order_item.destroy
        format.js
      end
    end
  end

  private
    def order_item_params
      params.require(:order_item).permit(
        :amount
      )
    end
end
