#encoding: utf-8

class Admin::DashboardController < ApplicationController

  layout 'admin'

  # GET /dashboard
  def index
    @inventory, @grand_total = current_store.inventory_valuation
  end

end
