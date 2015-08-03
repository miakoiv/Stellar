#encoding: utf-8

class OrderItemsController < ApplicationController

  before_action :authenticate_user!

  # PATCH/PUT /order_items/1
  def update
    @order_item = OrderItem.find(params[:id])

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
