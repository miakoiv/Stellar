#encoding: utf-8

class PagesController < ApplicationController

  before_action :find_page, only: [:show]

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
  end

  private
    def find_page
      @page = current_store.pages.friendly.find(params[:id])
      if request.path != show_page_path(@page)
        return redirect_to show_page_path(@page), status: :moved_permanently
      end
    end
end
