#encoding: utf-8

class OrdersController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may browse their orders.
  before_action :authenticate_user_or_skip!
  authority_actions duplicate: 'read', select: 'read'

  before_action :set_header_and_footer
  before_action :set_categories, only: [:index, :show, :edit]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :duplicate, :select]
  before_action :set_customers, only: [:new, :create]

  # GET /orders
  def index
    @query = saved_search_query('order', 'order_search')
    @search = OrderSearch.new(search_params)
    results = @search.results.complete
    @orders = results.page(params[:page])
    @timeline_orders = []
    #@timeline_orders = results.has_shipping.topical
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    authorize_action_for @order, at: current_store
  end

  # GET /orders/new
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

  # POST /orders
  def create
    authorize_action_for Order, at: current_store

    @order = current_store.orders.build(order_params.merge(user: current_user))
    @order.address_to_customer
    new_customer = @order.customer.new_record?

    @group = current_store.groups.find(order_params[:group_id])
    @order.includes_tax = @group.price_tax_included?
    @groups = new_customer ? all_groups : [@group]

    respond_to do |format|
      if @order.save
        @order.customer.groups << @group if new_customer
        user_session['shopping_cart_id'] = @order.id

        format.html { redirect_to cart_path, notice: t('.notice', order: @order) }
      else
        format.html { render :new }
      end
    end
  end

  # GET /orders/1/edit
  def edit
    authorize_action_for @order, at: current_store
  end

  # PATCH/PUT /orders/1
  # The checkout process calls this via AJAX any time the order status changes.
  # Completes an order if it's ready for completion. Orders targeted at another
  # customer are approved at completion. Responses are in JSON.
  # Returns an error if the order itself does not validate, or it has become
  # uncheckoutable until completed.
  # HTML responses are sent when the user edits her own completed orders.
  def update
    authorize_action_for @order, at: current_store

    respond_to do |format|
      if @order.update(order_params) && (@order.checkoutable? || @order.complete?)
        if @order.should_complete?
          @order.complete!
          @order.update(approved_at: Date.current) if @order.targeted?
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
    authorize_action_for @order, at: current_store

    @order.update(cancelled_at: Time.current)
    @order.email(:cancellation, @order.customer_string)

    respond_to do |format|
      format.html { redirect_to orders_path,
        notice: t('.notice', order: @order) }
    end
  end

  # GET /orders/1/duplicate
  def duplicate
    authorize_action_for @order, at: current_store

    @order.copy_items_to(shopping_cart)
    shopping_cart.recalculate!

    redirect_to cart_path, notice: t('.notice', order: @order)
  end

  # GET /orders/1/select
  # Users with customer selection role may use this action to select
  # a different order as the current shopping cart. If the selection
  # matches the default shopping cart, it is cleared instead.
  def select
    authorize_action_for @order, at: current_store

    if can_select_customer?
      if @order.targeted?
        user_session['shopping_cart_id'] = @order.id
      else
        user_session.delete('shopping_cart_id')
      end
      redirect_to cart_path
    else
      head :forbidden
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params[:id])
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order) {{}}.permit(
        :group_id, :order_type_id, :customer_id, :inventory_id,
        :completed_at, :shipping_at, :installation_at,
        :vat_number, :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :has_billing_address,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :notes,
        customer_attributes: [
          :id, :initial_group_id, :email, :name, :phone,
          :shipping_address, :shipping_postalcode,
          :shipping_city, :shipping_country_code,
          :billing_address, :billing_postalcode,
          :billing_city, :billing_country_code
        ]
      )
    end

    # The search is limited to the current user's personal history.
    def search_params
      @query.merge(store: current_store, user_id: current_user.id)
    end
end
