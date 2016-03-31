#encoding: utf-8

class Admin::OrdersController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  authorize_actions_for Order
  authority_actions forward: 'read'
  before_action :set_order, only: [:show, :edit, :update, :destroy, :forward]

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

  # GET /admin/orders/1/forward
  def forward
    failed_items = @order.forward_to(shopping_cart)
    shopping_cart.recalculate!

    if failed_items.any?
      redirect_to cart_path, alert: t('.failed', order: @order, failed: failed_items.to_sentence)
    else
      redirect_to cart_path, notice: t('.notice', order: @order)
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
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end

    # Restrict searching to orders in current store managed by current user.
    def search_params
      @query.merge(
        store_id: current_store.id,
        manager_id: current_user.id
      )
    end
end
