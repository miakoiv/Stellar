#encoding: utf-8

class Admin::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :quote, :forward, :approve, :review, :conclude, :add_products]

  authority_actions quote: 'read', forward: 'read', approve: 'update', review: 'update', conclude: 'update', add_products: 'update'

  layout 'admin'

  # GET /admin/orders
  # GET /admin/orders.json
  def index
    authorize_action_for Order, at: current_store
    @query = saved_search_query('order', 'admin_order_search')
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
    @timeline_orders = results.has_shipping.topical
  end

  # GET /admin/orders/1
  def show
    authorize_action_for Order, at: current_store
  end

  # GET /admin/orders/new
  def new
    authorize_action_for Order, at: current_store
    @order = current_store.orders.build(completed_at: Time.current)
  end

  # GET /admin/orders/1/edit
  def edit
    authorize_action_for Order, at: current_store
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
    authorize_action_for Order, at: current_store
    @order = current_store.orders.build(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to edit_admin_order_path(@order),
          notice: t('.notice', order: @order) }
        format.json { render :show, status: :created, location: admin_order_path(@order) }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/orders/1
  # PATCH/PUT /admin/orders/1.json
  def update
    authorize_action_for Order, at: current_store

    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to admin_order_path(@order),
          notice: t('.notice', order: @order) }
        format.json { render :show, status: :ok, location: admin_order_path(@order) }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/orders/1/quote
  def quote
    authorize_action_for Order, at: current_store
    redirect_to admin_order_path(@order), notice: t('.notice', order: @order)
  end

  # GET /admin/orders/1/forward
  def forward
    authorize_action_for Order, at: current_store
    @order.forward_to(shopping_cart)
    shopping_cart.recalculate!

    redirect_to cart_path, notice: t('.notice', order: @order)
  end

  # PATCH/PUT /admin/orders/1/approve
  def approve
    authorize_action_for Order, at: current_store
    @order.update(approved_at: Date.current)

    respond_to do |format|
      format.js
    end
  end

  # GET /admin/orders/1/review
  def review
    authorize_action_for Order, at: current_store
  end

  # PATCH/PUT /admin/orders/1/conclude
  def conclude
    authorize_action_for Order, at: current_store
    @order.update(concluded_at: Date.current)

    respond_to do |format|
      format.js
    end
  end

  # POST /admin/orders/1/add_products
  def add_products
    authorize_action_for Order, at: current_store
    product_ids = params[:order][:product_ids_string].split(',').map(&:to_i)

    product_ids.each do |product_id|
      @order.insert(@current_store.products.live.find(product_id), 1, nil)
    end
    @order.recalculate!

    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_store.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :completed_at, :shipping_at, :installation_at,
        :approved_at, :concluded_at, :vat_number,
        :external_number, :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :notes
      )
    end

    # Limit the search to available order types and default to the first one.
    def search_params
      @query.merge(store: current_store).reverse_merge({
        'order_type_id' => OrderType.available_for(current_group).first.id
      })
    end
end
