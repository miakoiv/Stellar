#encoding: utf-8

class Admin::ReportsController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  # GET /admin/reports
  def index
    @inventory = current_store.inventory_valuation
  end

end
