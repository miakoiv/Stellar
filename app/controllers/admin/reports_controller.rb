class Admin::ReportsController < AdminController

  before_action :set_variant, only: [:sales, :purchases]

  # GET /admin/reports
  def index
  end

  # GET /admin/reports/inventory
  def inventory
    query = saved_search_query('inventory_item', 'admin_inventory_item_report_search')
    query.merge!(store_id: current_store.id, reported: true)

    respond_to do |format|
      format.html {
        @search = InventoryItemSearch.new(query)
      }
      format.json {
        search = InventoryItemSearch.new(
          query.merge(tabular_params)
        )
        @inventory = Reports::Inventory.new(search)
      }
    end
  end

  # GET /admin/reports/sales
  def sales
    @order_types = current_group.incoming_order_types
    return head :bad_request if @order_types.empty?
    query = saved_search_query('order_report_row', 'admin_sales_order_report_row_search')
    set_default_order_types!(query)
    query['temporal_unit'] ||= 'day'

    respond_to do |format|
      format.html {
        @search = OrderReportRowSearch.new(query)
      }
      format.js
      format.json {
        search = OrderReportRowSearch.new(
          query.merge(view_params).merge(tabular_params)
        )
        @sales = Reports::Sales.new(search)
      }
    end
  end

  # GET /admin/reports/sales_tax
  def sales_tax
    @order_types = current_group.incoming_order_types
    return head :bad_request if @order_types.empty?
    query = saved_search_query('order_report_row', 'admin_sales_order_report_row_search')
    set_default_order_types!(query)

    respond_to do |format|
      format.json {
        search = OrderReportRowSearch.new(
          query.merge(view_params).merge(tabular_params)
        )
        @sales = Reports::Sales.new(search)
      }
    end
  end

  # GET /admin/reports/product/1/sales.js
  def product_sales
    @product = current_store.products.find(params[:product_id])
    @order_types = current_group.incoming_order_types
    return head :bad_request if @order_types.empty?
    query = saved_search_query('order_report_row', 'admin_sales_order_report_row_search')
    set_default_order_types!(query)
    @search = OrderItemSearch.new(query.merge('product_id': @product.id, concluded_only: true))
    @order_items = @search.results

    respond_to :js
  end

  # GET /admin/reports/purchases
  def purchases
    @order_types = current_group.outgoing_order_types
    return head :bad_request if @order_types.empty?
    query = saved_search_query('order_report_row', 'admin_purchases_order_report_row_search')
    set_default_order_types!(query)
    query['temporal_unit'] ||= 'day'

    respond_to do |format|
      format.html {
        @search = OrderReportRowSearch.new(query)
      }
      format.js
      format.json {
        search = OrderReportRowSearch.new(
          query.merge(view_params).merge(tabular_params)
        )
        @purchases = Reports::Sales.new(search)
      }
    end
  end

  private
    # Chart views can be requested as variants.
    def set_variant
      request.variant = :chart if params[:variant] == 'chart'
    end

    # Params specifying a view but not saved with the search query.
    def view_params
      params.fetch(:view_params) {{}}
    end

    def set_default_order_types!(query)
      types = query['order_type'] || []
      types = @order_types.pluck(:id) if types.blank? || types == ['']
      query['order_type'] = types
    end

    # Params specific to the inherent controls tabular provides.
    def tabular_params
      sort = params[:sort].presence || {name: 'product_title', dir: 'asc'}
      search = params[:q]
      {
        sort: "#{sort[:name]} #{sort[:dir]}",
        keyword: search
      }
    end
end
