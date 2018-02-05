#encoding: utf-8

class Pos::OrdersController < ApplicationController

  before_action :authenticate_user!

  layout 'point_of_sale'

  def index
  end
end
