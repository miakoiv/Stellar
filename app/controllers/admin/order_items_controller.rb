#encoding: utf-8

class Admin::OrderItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order_item

  # No layout, this controller never renders HTML.

  authorize_actions_for OrderItem

  # PATCH/PUT /admin/order_items/1
  def update
    @order_item = OrderItem.find(params[:id])

    respond_to do |format|
      if @order_item.update(order_item_params)
        format.js
      else
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_order_item
      @order_item = OrderItem.find(params[:id])
    end

    def order_item_params
      params.require(:order_item).permit(
        :price
      )
    end
end
