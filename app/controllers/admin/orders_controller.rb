class Admin::OrdersController < AdminController

  before_action :set_order, except: [:index, :incoming, :outgoing, :new, :create]

  authority_actions incoming: 'read', outgoing: 'read', forward: 'read', preview: 'update', approve: 'update', review: 'update', conclude: 'update'

  # GET /admin/orders
  # GET /admin/orders.json
  def index
    authorize_action_for Order, at: current_store
    query = saved_search_query('order', 'admin_order_search')
    @search = OrderSearch.new(query.merge(search_constrains))
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/incoming
  def incoming
    authorize_action_for Order, at: current_store

    @order_types = current_group.incoming_order_types
    return head :bad_request if @order_types.empty?

    @users = current_store.users.with_role(:order_manage, current_store)
    query = saved_search_query('order', 'incoming_admin_order_search')
    @search = OrderSearch.new(query.merge(search_constrains))
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/outgoing
  def outgoing
    authorize_action_for Order, at: current_store

    @order_types = current_group.outgoing_order_types
    return head :bad_request if @order_types.empty?

    @users = current_store.users.with_role(:order_manage, current_store)
    query = saved_search_query('order', 'outgoing_admin_order_search')
    query.reverse_merge!('order_type' => @order_types.first)
    @search = OrderSearch.new(query.merge(search_constrains))
    results = @search.results
    @orders = results.page(params[:page])
  end

  # GET /admin/orders/1
  def show
    authorize_action_for Order, at: current_store
    track @order
  end

  # GET /admin/orders/new
  def new
    authorize_action_for Order, at: current_store

    @groups = current_store.non_default_groups
    @order = current_store.orders.build(order_params)
    @order.billing_group ||= @groups.first
    @order.shipping_group ||= @order.billing_group
    @order.assign_addresses

    respond_to :html, :js
  end

  # GET /admin/orders/1/edit
  def edit
    authorize_action_for Order, at: current_store
    track @order
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
    authorize_action_for Order, at: current_store

    @groups = current_store.non_default_groups
    @order = current_store.orders.build(order_params.merge(user: current_user))
    @order.includes_tax = @order.billing_group.price_tax_included?

    respond_to do |format|
      if @order.save
        track @order

        format.html { redirect_to edit_admin_order_path(@order), notice: t('.notice', order: @order) }
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
        track @order
        if should_finalize?
          @order.complete!(false)
          @order.update(approved_at: Date.current)
        end
        format.html { redirect_to edit_admin_order_path(@order),
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
    track @order
    @order.destroy

    respond_to do |format|
      format.html { redirect_to admin_orders_path,
        notice: t('.notice', order: @order) }
    end
  end

  # GET /admin/orders/1/forward
  def forward
    authorize_action_for Order, at: current_store
    @order.forward_to(shopping_cart)
    shopping_cart.recalculate!

    redirect_to cart_path, notice: t('.notice', order: @order)
  end

  # GET /admin/orders/1/preview
  def preview
    authorize_action_for Order, at: current_store
  end

  # PATCH/PUT /admin/orders/1/approve
  def approve
    authorize_action_for Order, at: current_store
    @order.update(approved_at: Date.current)
    track @order

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
    track @order

    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_store.orders.unscope(where: :cancelled_at).find(params[:id])
    end

    def should_finalize?
      order_params[:is_final] == '1'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {}).permit(
        :user_id, :billing_group_id, :shipping_group_id,
        :order_type_id, :inventory_id,
        :completed_at, :shipping_at, :installation_at,
        :approved_at, :concluded_at, :cancelled_at,
        :vat_number, :external_number, :your_reference, :our_reference,
        :message, :notes, :is_final,
        :customer_email, :contact_email, :separate_shipping_address,
        billing_address_attributes: [
          :id, :name, :phone, :company, :department,
          :address1, :address2, :postalcode, :city, :country_code
        ],
        shipping_address_attributes: [
          :id, :name, :phone, :company, :department,
          :address1, :address2, :postalcode, :city, :country_code
        ]
      )
    end

    # Limit the search to orders in current store and
    # order types set by the action.
    def search_constrains
      {store: current_store, order_type: @order_types}
    end
end
