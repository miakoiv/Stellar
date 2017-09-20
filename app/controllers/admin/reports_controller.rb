#encoding: utf-8

class Admin::ReportsController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  # GET /admin/reports
  def index
  end

  # GET /admin/reports/inventory
  def inventory
    @search = InventoryItemSearch.new(inventory_params)

    respond_to do |format|
      format.html
      format.json {
        @inventory = Reports::Inventory.new(@search)
      }
    end
  end

  # GET /admin/reports/sales
  def sales
    @order_types = current_user.incoming_order_types
    return redirect_to admin_reports_path if @order_types.empty?
    @query = saved_search_query('order_report_row', 'admin_order_report_row_search')
    @search = OrderReportRowSearch.new(order_report_params)

    respond_to do |format|
      format.html
      format.json {
        @sales = Reports::Sales.new(@search)
      }
    end
  end

  # GET /admin/reports/purchases
  def purchases
    @order_types = current_user.outgoing_order_types
    return redirect_to admin_reports_path if @order_types.empty?
    @query = saved_search_query('order_report_row', 'admin_order_report_row_search')
    @search = OrderReportRowSearch.new(order_report_params)

    respond_to do |format|
      format.html
      format.json {
        @purchases = Reports::Sales.new(@search)
      }
    end
  end

  private
    def order_report_params
      @query.reverse_merge({
        'order_type_id' => @order_types.first.id
      }).merge(tabular_params)
    end

    def inventory_params
      {store: current_store.id}.merge(tabular_params)
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
