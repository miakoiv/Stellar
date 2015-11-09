#encoding: utf-8

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
    if @order_item.update(order_item_params)
      @order_item.destroy if @order_item.amount < 1
      @order.apply_shipping_cost!
      @order.apply_promotions!
    end
  end

  # DELETE /order_items/1
  def destroy
    if @order_item.destroy
      @order.apply_shipping_cost!
      @order.apply_promotions!
    end
  end

  private
    def set_order_and_item
      @order = shopping_cart
      @order_item = @order.order_items.find(params[:id])
    end

    def order_item_params
      params.require(:order_item).permit(
        :amount
      )
    end
end
