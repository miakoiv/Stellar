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

  # GET /admin/images/1/edit.js
  def edit
    @image = current_store.images.find(params[:id])

    respond_to :js
  end

  # POST /admin/images
  def create
    @image = current_store.images.build(image_params)

    respond_to do |format|
      if @image.save
        track @image
        format.json { render json: @image, status: 200 } # for dropzone
      else
        format.html { render json: {error: t('.error')} }
        format.json { render json: {error: @image.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # DELETE /admin/images/1
  def destroy
    @image = current_store.images.find(params[:id])
    authorize_action_for @image, at: current_store

    respond_to do |format|
      if @image.destroy
        track @image
        format.js
      end
    end
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
