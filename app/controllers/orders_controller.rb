#encoding: utf-8

class OrdersController < ApplicationController

  # GET /orders
  def index
    @orders = current_user.orders
  end

end
