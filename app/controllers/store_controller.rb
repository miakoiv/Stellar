#encoding: utf-8

class StoreController < ApplicationController

  before_action :set_categories

  # GET /
  def index
  end

  private
    def set_categories
      @categories = current_brand.categories
    end
end
