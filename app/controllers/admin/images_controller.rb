#encoding: utf-8

class Admin::ImagesController < ApplicationController

  # No layout, this controller never renders HTML.

  # GET /admin/images
  def index
    @query = saved_search_query('image', 'admin_image_search')
    @search = ImageSearch.new(search_params)
    @images = @search.results.page(params[:page])

    respond_to :js
  end

  # GET /admin/images/1/select
  def select
    @image = current_store.images.find(params[:id])
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:attachment)
    end

    # Restrict searching to images in current store.
    def search_params
      @query.merge(
        store: current_store
      )
    end
end
