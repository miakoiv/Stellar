#encoding: utf-8

class Admin::ReportsController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  # GET /admin/reports
  def index
    @inventory = current_store.inventory_valuation
  end

end
