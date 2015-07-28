#encoding: utf-8

class Admin::DashboardController < ApplicationController

  layout 'admin'

  # GET /dashboard
  def index
    products = current_store.products.categorized
    @inventory = current_store.inventory_valuation(products)
  end

end
