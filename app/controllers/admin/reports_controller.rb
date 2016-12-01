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
    @query = saved_search_query('order_item', 'admin_order_item_search')
    @sales = Reports::Sales.new(sales_search_params)
  end

  private
    def sales_search_params
      @query.merge(store_id: current_store.id).reverse_merge({
        'order_type_id' => current_user.incoming_order_types.first.id
      })
    end
end
