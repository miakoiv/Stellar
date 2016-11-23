#encoding: utf-8

class Admin::ReportsController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  # GET /admin/reports
  def index
  end

  # GET /admin/reports/inventory
  def inventory
    @inventory = Reports::Inventory.new(current_store)
  end
end
