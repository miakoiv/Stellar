#encoding: utf-8

class Admin::OrderItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order_and_item

  # No layout, this controller never renders HTML.

  # PATCH/PUT /admin/order_items/1
  def update
    authorize_action_for @order_item, at: current_store

    respond_to do |format|
      if @order_item.update(order_item_params)
        @order_item.reload
        @order.recalculate!(current_group)
        format.js { render :update }
      else
        format.js { render :rollback }
      end
    end
  end

  private
    def set_order_and_item
      @order_item = OrderItem.find(params[:id])
      @order = @order_item.order
    end

    def order_item_params
      params.require(:order_item).permit(
        :amount, :price
      )
    end
end
