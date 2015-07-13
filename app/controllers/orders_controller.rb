#encoding: utf-8

class OrdersController < ApplicationController

  before_action :set_order, only: [:edit, :update, :destroy]

  # GET /orders
  def index
    @orders = current_user.orders
  end

  # GET /orders/edit/1
  def edit
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to edit_order_path(@order), notice: 'Order was successfully updated.' }
        format.json { render :edit, status: :ok, location: edit_order_path(@order) }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :user_id, :order_type_id, :ordered_at, :shipping_at, :approval,
        :company_name, :contact_person, :billing_address, :shipping_address,
        :notes
      )
    end
end
