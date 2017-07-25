#encoding: utf-8

class Admin::ReportsController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  # GET /admin/reports
  def index
  end

  # GET /admin/reports/inventory
  def inventory
    @inventory = Reports::Inventory.new(store_id: current_store.id)
  end

  # GET /admin/reports/sales
  def sales
    @order_types = current_user.incoming_order_types
    return redirect_to admin_reports_path if @order_types.empty?
    @query = saved_search_query('order_item', 'admin_order_item_search')
    @sales_data = Reports::Sales.new(search_params)
  end

  # GET /admin/reports/purchases
  def purchases
    @order_types = current_user.outgoing_order_types
    return redirect_to admin_reports_path if @order_types.empty?
    @query = saved_search_query('order_item', 'admin_order_item_search')
    @purchases_data = Reports::Purchases.new(search_params)
  end

  private
    def search_params
      @query.merge(store_id: current_store.id).reverse_merge({
        'order_type_id' => @order_types.first.id
      })
    end
end
