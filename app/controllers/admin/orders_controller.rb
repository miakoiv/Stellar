#encoding: utf-8

class Admin::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, except: [:index, :incoming, :outgoing, :new, :create]
  before_action :set_customers, only: [:new, :create]

  authority_actions incoming: 'read', outgoing: 'read', quote: 'read', forward: 'read', approve: 'update', review: 'update', conclude: 'update'

  layout 'admin'

  # GET /admin/orders
  # GET /admin/orders.json
  def index
    authorize_action_for Order, at: current_store
    @query = saved_search_query('order', 'admin_order_search')
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/incoming
  def incoming
    authorize_action_for Order, at: current_store

    @order_types = current_group.incoming_order_types
    return render nothing: true, status: :bad_request if @order_types.empty?

    @query = saved_search_query('order', 'incoming_admin_order_search')
    @query.reverse_merge!('order_type' => @order_types.first)
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/outgoing
  def outgoing
    authorize_action_for Order, at: current_store

    @order_types = current_group.outgoing_order_types
    return render nothing: true, status: :bad_request if @order_types.empty?

    @query = saved_search_query('order', 'outgoing_admin_order_search')
    @query.reverse_merge!('order_type' => @order_types.first)
    @search = OrderSearch.new(search_params)
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/1
  def show
    authorize_action_for Order, at: current_store
  end

  # GET /admin/orders/new
  def new
    authorize_action_for Order, at: current_store

    if order_params[:customer_id].present?
      customer = current_store.users.find(order_params[:customer_id])
      @group = customer.group(current_store)
      @groups = [@group]
    else
      customer = User.new(
        shipping_country: Country.default,
        billing_country: Country.default
      )
      @groups = all_groups
      @group = @groups.first
    end

    @order = current_store.orders.build(
      group_id: @group.id,
      order_type: @group.outgoing_order_types.first
    )
    @order.customer = customer

    respond_to :html, :js
  end

  # GET /admin/orders/1/edit
  def edit
    authorize_action_for Order, at: current_store
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
    authorize_action_for Order, at: current_store

    @order = current_store.orders.build(order_params.merge(user: current_user))
    @order.address_to_customer
    new_customer = @order.customer.new_record?

    @group = current_store.groups.find(order_params[:group_id])
    @groups = new_customer ? all_groups : [@group]

    respond_to do |format|
      if @order.save
        @order.customer.groups << @group if new_customer

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
        @order.complete! if should_complete?
        format.html { redirect_to admin_order_path(@order),
          notice: t('.notice', order: @order) }
        format.json { render :show, status: :ok, location: admin_order_path(@order) }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/orders/1
  def destroy
    authorize_action_for Order, at: current_store
    @order.destroy

    respond_to do |format|
      format.html { redirect_to admin_orders_path,
        notice: t('.notice', order: @order) }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_store.orders.find(params[:id])
    end

    def set_customers
      @customers = UserSearch.new(
        store: current_store,
        except_group: current_store.default_group
      ).results
    end

    def all_groups
      current_store.groups.not_including(current_store.default_group)
    end

    def should_complete?
      order_params[:is_complete] == '1'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order) {{}}.permit(
        :user_id, :group_id,
        :order_type_id, :customer_id, :inventory_id,
        :completed_at, :shipping_at, :installation_at,
        :approved_at, :concluded_at, :vat_number,
        :external_number, :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :notes, :is_complete,
        customer_attributes: [
          :id, :initial_group_id, :email, :name, :phone,
          :shipping_address, :shipping_postalcode,
          :shipping_city, :shipping_country_code,
          :billing_address, :billing_postalcode,
          :billing_city, :billing_country_code
        ]
      )
    end

    # Limit the search to available order types and default to the first one.
    def search_params
      @query.merge(store: current_store)
    end
end
