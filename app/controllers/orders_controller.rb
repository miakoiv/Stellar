#encoding: utf-8

class OrdersController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may browse their orders.
  before_action :authenticate_user_or_skip!
  authority_actions confirm: 'read', duplicate: 'read'

  before_action :set_order, only: [:show, :edit, :update, :destroy, :confirm, :duplicate]

  # GET /orders
  def index
    @orders_by_type = current_user.orders.complete.group_by(&:order_type)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    authorize_action_for @order
  end

  # GET /orders/1/edit
  def edit
    authorize_action_for @order
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    authorize_action_for @order

    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to edit_order_path(@order),
          notice: t('.notice', order: @order) }
        format.json { render :edit, status: :ok, location: edit_order_path(@order) }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  def destroy
    authorize_action_for @order

    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_path,
        notice: t('.notice', order: @order) }
    end
  end

  # GET /orders/1/confirm
  def confirm
    authorize_action_for @order

    OrderMailer.order_confirmation(@order).deliver_later
    redirect_to orders_path
  end

  # GET /orders/1/duplicate
  def duplicate
    authorize_action_for @order

    order = shopping_cart
    @order.order_items.each do |order_item|
      order.insert!(order_item.product, order_item.amount)
    end

    redirect_to show_cart_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.complete.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :completed_at, :shipping_at,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :billing_address, :billing_postalcode,
        :billing_city, :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end
end
