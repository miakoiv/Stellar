#encoding: utf-8

class Admin::DashboardController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  # GET /admin/dashboard
  def index
  end
end
