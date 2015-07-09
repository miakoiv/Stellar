#encoding: utf-8

class OrdersController < ApplicationController

  before_action :set_order, only: [:edit, :destroy]

  # GET /orders
  def index
    @orders = current_user.orders
  end

  # GET /orders/edit/1
  def edit
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_path, notice: 'Order deleted.'}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end
end
