#encoding: utf-8

class StoreController < ApplicationController

  before_action :set_categories

  # GET /
  def index
    @category = current_brand.categories.first
    @products = @category.products

    render :show_category
  end

  # GET /category/1
  def show_category
    @category = Category.find(params[:category_id])
    @products = @category.products
  end

  private
    def set_categories
      @categories = current_brand.categories
    end
end
