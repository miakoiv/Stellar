#encoding: utf-8

class PagesController < ApplicationController

  before_action :set_pages

  # GET /pages
  def index
    redirect_to show_page_path(@pages.first)
  end

  # GET /pages/1
  def show
    @page = current_store.pages.find(params[:id])
  end

  private
    def set_pages
      @pages = current_store.pages.top_level
    end
end
