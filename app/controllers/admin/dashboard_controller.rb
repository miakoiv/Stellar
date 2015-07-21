#encoding: utf-8

class Admin::DashboardController < ApplicationController

  layout 'admin'

  # GET /dashboard
  def index
    @products = current_store.products
  end

end
