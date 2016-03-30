#encoding: utf-8

class Admin::DashboardController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  # GET /admin/dashboard
  def index
    @search = OrderSearch.new(order_search_params)
    @orders = @search.results.topical
  end

  private
    def order_search_params
      {
        store_id: current_store.id,
        manager_id: current_user.id
      }
    end
end
