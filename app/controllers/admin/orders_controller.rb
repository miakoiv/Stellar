#encoding: utf-8

class Admin::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :quote, :forward, :add_products]

  authority_actions quote: 'read', forward: 'read', add_products: 'update'
  authorize_actions_for Order

  layout 'admin'

  # GET /admin/orders
  # GET /admin/orders.json
  def index
    @query = saved_search_query('order', 'admin_order_search')
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
    @timeline_orders = results.has_shipping.topical
  end

  # GET /admin/orders/1
  # GET /admin/orders/1.xml
  def show
    respond_to do |format|
      format.html
      format.xml
    end
  end

  # GET /admin/orders/new
  def new
    @order = current_store.orders.build(completed_at: Time.current)
  end

  # GET /admin/orders/1/edit
  def edit
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
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
    OrderMailer.quotation(@order).deliver_later
    redirect_to admin_order_path(@order), notice: t('.notice', order: @order)
  end

  # GET /admin/orders/1/forward
  def forward
    @order.forward_to(shopping_cart)
    shopping_cart.reappraise!(current_pricing)
    shopping_cart.recalculate!

    redirect_to cart_path, notice: t('.notice', order: @order)
  end

  # POST /admin/orders/1/add_products
  def add_products
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
      @order = current_store.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :completed_at, :shipping_at, :installation_at,
        :approval, :conclusion,
        :external_number, :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end

    # Limit the search to available order types and default to the first one.
    def search_params
      @query.merge(store_id: current_store.id).reverse_merge({
        'order_type_id' => current_user.available_order_types.first.id
      })
    end
end
