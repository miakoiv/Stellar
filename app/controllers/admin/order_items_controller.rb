class Admin::OrderItemsController < AdminController

  before_action :set_order_and_item, except: [:index, :create]

  # GET /admin/order_items
  def index
    authorize_action_for OrderItem, at: current_store

    @order_types = current_group.incoming_order_types
    query = saved_search_query('order_item', 'admin_order_item_search')
    @search = OrderItemSearch.new(query.merge(search_constrains))
    results = @search.results.pending
    @order_items = results.page(params[:page])
    @products = current_store.products
      .find((query['product_id'] || []).reject(&:blank?))
  end

  # POST /admin/orders/1/order_items.js
  # Use Order#insert to create order items correctly.
  def create
    authorize_action_for OrderItem, at: current_store
    @order = current_store.orders.find(params[:order_id])
    @product = if order_item_params[:customer_code].present?
      current_store.products.live.find_by(customer_code: order_item_params[:customer_code])
    else
      current_store.products.live.find_by(id: order_item_params[:product_id])
    end
    amount = order_item_params[:amount].to_i
    options = {lot_code: lot_code_or_serial}

    respond_to do |format|
      if @order_item = @order.insert(@product, amount, @order.billing_group, options)
        track @order_item, @order
        @order.recalculate!
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/order_items/1.js
  def update
    authorize_action_for @order_item, at: current_store

    if @order_item.update(order_item_params)
      track @order_item, @order
      @order.recalculate!
    end

    respond_to :js
  end

  # DELETE /admin/order_items/1.js
  def destroy
    authorize_action_for @order_item, at: current_store

    if @order_item.destroy
      track @order_item, @order
      @order.recalculate!
    end

    respond_to :js
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order_and_item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_item_params
    params.require(:order_item).permit(
      :product_id, :amount, :lot_code, :serial,
      :price, :customer_code
    )
  end

  def search_constrains
    {store: current_store, order_type: @order_types, all_time: true}
  end

  # Use lot code if found, serial otherwise.
  def lot_code_or_serial
    order_item_params[:lot_code].presence || order_item_params[:serial].presence
  end
end
