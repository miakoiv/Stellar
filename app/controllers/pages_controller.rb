#encoding: utf-8

class PagesController < ApplicationController

  # GET /pages
  def index
    @page = current_store.pages.first

    render :show
  end

  # GET /pages/1
  def show
    @page = current_store.pages.find(params[:id])
  end
end
