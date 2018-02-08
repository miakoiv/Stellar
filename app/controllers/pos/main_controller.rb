#encoding: utf-8

class Pos::MainController < ApplicationController

  before_action :authenticate_user!

  layout 'point_of_sale'

  # GET /pos/index
  def index
    @order = shopping_cart
    @order_types = current_group.outgoing_order_types
  end
end
