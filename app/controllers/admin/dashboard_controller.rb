#encoding: utf-8

class Admin::DashboardController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  # GET /admin/dashboard
  def index
  end
end
