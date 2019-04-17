class OrdersController < BaseStoreController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may browse their orders.
  before_action :authenticate_user_or_skip!
  before_action :set_categories, only: [:index, :show, :edit]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :duplicate]

  authority_actions duplicate: 'read', select: 'read', preview: 'read', claim: 'update'

  # GET /orders
  def index
    query = saved_search_query('order', 'order_search')
    @search = OrderSearch.new(query.merge(search_constrains))
    results = @search.results.complete
    @orders = results.page(params[:page])
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    authorize_action_for @order, at: current_store
    track @order

    respond_to :js, :json, :html
  end

  # GET /orders/new
  def new
    authorize_action_for Order, at: current_store

    @groups = current_store.non_default_groups
    @order = current_store.orders.build(order_params)
    @order.billing_group ||= @groups.first
    @order.shipping_group ||= @order.billing_group
    @order.assign_addresses

    respond_to :html, :js
  end

  # GET /orders/1/edit
  def edit
    authorize_action_for @order, at: current_store
    track @order
  end

  # POST /orders
  def create
    authorize_action_for Order, at: current_store

    @groups = current_store.non_default_groups
    @order = current_store.orders.build(order_params.merge(user: current_user))
    @order.includes_tax = @order.billing_group.price_tax_included?

    respond_to do |format|
      if @order.save
        track @order
        user_session['shopping_cart_id'] = @order.id

        format.html { redirect_to cart_path, notice: t('.notice', order: @order) }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /orders/1
  # The checkout process calls this via AJAX any time the order status changes.
  # Completes an order if it's ready for completion. Quotations are approved
  # at completion. Responses are in JSON.
  # Returns an error if the order itself does not validate, or it has become
  # uncheckoutable until completed.
  # HTML responses are sent when the user edits her own completed orders.
  def update
    authorize_action_for @order, at: current_store

    respond_to do |format|
      if @order.update(order_params) && (@order.checkoutable? || @order.complete?)
        if @order.should_complete?
          @order.complete!
          @order.update(approved_at: Date.current) if @order.quotation?
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
    track @order

    @order.update(cancelled_at: Time.current)

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
    @order = current_store.orders.find(params[:id])
    authorize_action_for @order, at: current_store

    if can_select_customer?
      if @order != default_shopping_cart
        user_session['shopping_cart_id'] = @order.id
      else
        user_session.delete('shopping_cart_id')
      end
      redirect_to cart_path
    else
      head :forbidden
    end
  end

  # GET /orders/1/preview
  # Users with customer selection role may preview quotes (orders)
  # and claim them as their own to continue working on them.
  def preview
    @order = current_group.user_orders.at(current_store).find(params[:id])
    authorize_action_for Order, at: current_store
  end

  # PATCH/PUT /orders/1/claim
  def claim
    authorize_action_for Order, at: current_store
    @order = current_group.user_orders.at(current_store).find(params[:id])
    if can_select_customer?
      previous_owner = @order.user
      @order.update(user: current_user)
      user_session['shopping_cart_id'] = @order.id
      redirect_to cart_path, notice: t('.notice', from: previous_owner)
    else
      head :forbidden
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {}).permit(
        :billing_group_id, :shipping_group_id,
        :order_type_id, :inventory_id,
        :completed_at, :shipping_at, :installation_at,
        :vat_number, :your_reference, :our_reference, :message, :notes,
        :customer_email, :contact_email, :separate_shipping_address,
        billing_address_attributes: [
          :id, :name, :phone, :company,
          :address1, :address2, :postalcode, :city, :country_code
        ],
        shipping_address_attributes: [
          :id, :name, :phone, :company,
          :address1, :address2, :postalcode, :city, :country_code
        ]
      )
    end

    # The search is limited to the current user's personal history.
    def search_constrains
      {store: current_store, user_id: current_user.id}
    end
end
