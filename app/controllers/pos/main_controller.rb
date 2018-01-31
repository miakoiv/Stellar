#encoding: utf-8

class Pos::MainController < ApplicationController

  before_action :authenticate_user!

  def wiselinks_layout
    'point_of_sale'
  end
  layout 'point_of_sale'

  # GET /pos/index
  def index
  end
end
