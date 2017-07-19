#encoding: utf-8

class Admin::SectionsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!

  # No layout, this controller never renders HTML.


end
