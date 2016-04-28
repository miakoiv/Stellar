#encoding: utf-8

class OrdersController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may browse their orders.
  before_action :authenticate_user_or_skip!
  authority_actions quote: 'read', duplicate: 'read', add_products: 'update'

  before_action :set_pages
  before_action :set_order, only: [:show, :edit, :update, :destroy, :quote, :duplicate, :add_products]

  # GET /orders
  def index
    @query = saved_search_query('order', 'order_search')
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
    @timeline_orders = results.has_shipping.topical
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
  # The checkout process calls this via AJAX and a successful update completes
  # the order and sends confirmation e-mail. Responses are in JSON.
  # HTML responses are sent when the user edits her own completed orders.
  def update
    authorize_action_for @order

    respond_to do |format|
      if @order.update(order_params)
        if !@order.complete? && @order.paid?
          @order.complete!
          OrderMailer.order_confirmation(@order).deliver_later
        end
        format.json { render json: @order }
        format.html { redirect_to order_path(@order), notice: t('.notice', order: @order) }
      else
        format.json { render json: @order.errors, status: :unprocessable_entity }
        format.html { render :edit }
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

  # FIXME: this probably doesn't belong here, but at admin/orders
  # GET /orders/1/quote
  def quote
    authorize_action_for @order

    OrderMailer.quotation(@order).deliver_later
    redirect_to order_path(@order), notice: t('.notice', order: @order)
  end

  # GET /orders/1/duplicate
  def duplicate
    authorize_action_for @order

    failed_items = @order.copy_items_to(shopping_cart)
    shopping_cart.reappraise!(current_pricing)
    shopping_cart.recalculate!

    if failed_items.any?
      redirect_to cart_path, alert: t('.failed', order: @order, failed: failed_items.to_sentence)
    else
      redirect_to cart_path, notice: t('.notice', order: @order)
    end
  end

  # FIXME: move this to admin/orders
  # POST /orders/1/add_products
  def add_products
    authorize_action_for @order

    product_ids = params[:order][:product_ids_string].split(',').map(&:to_i)

    product_ids.each do |product_id|
      @order.insert(@current_store.products.live.find(product_id), 1, current_pricing)
    end
    @order.recalculate!

    respond_to do |format|
      format.js
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
        :order_type_id, :completed_at, :shipping_at, :installation_at,
        :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :has_billing_address,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end

    # The search is limited to the current user's personal history.
    def search_params
      @query.merge(user_id: current_user.id)
    end
end
