#encoding: utf-8

class OrdersController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may browse their orders.
  before_action :authenticate_user_or_skip!
  authority_actions duplicate: 'read'

  before_action :set_pages
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @query = saved_search_query('order', 'order_search')
    @search = OrderSearch.new(search_params)
    @orders = @search.results.page(params[:page])
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
  def update
    authorize_action_for @order

    respond_to do |format|
      if @order.update(order_params)
        if @order.paid?
          @order.complete!
          OrderMailer.order_confirmation(@order).deliver_later
        end
        format.json { render json: @order }
      else
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

  # GET /orders/1/duplicate
  def duplicate
    @order = current_store.orders.find(params[:id])
    authorize_action_for @order

    failed_items = @order.copy_items_to(shopping_cart)
    if failed_items.any?
      redirect_to cart_path, alert: t('.failed', order: @order, failed: failed_items.to_sentence)
    else
      redirect_to cart_path, notice: t('.notice', order: @order)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :completed_at, :shipping_at,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_phone, :has_billing_address,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end

    # Restrict searching to orders of current user.
    def search_params
      @query.merge(
        user_id: current_user.id
      )
    end
end
