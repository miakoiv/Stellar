#encoding: utf-8

class PagesController < ApplicationController

  before_action :set_pages

  # GET /pages
  def index
    if @pages.any?
      redirect_to show_page_path(@pages.first)
    else
      redirect_to store_path
    end
  end

  # GET /pages/1
  def show
    @page = current_store.pages.friendly.find(params[:id])
  end

  private
    def set_pages
      @pages = current_store.pages.top_level.ordered
    end
end
