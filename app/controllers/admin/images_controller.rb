#encoding: utf-8

class Admin::ImagesController < ApplicationController

  before_action :set_product, only: [:new, :create]

  # GET /admin/images/1
  # This is only called by Dropzone as callback for success.
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  # GET /admin/products/1/images/new
  def new
    @image = @product.images.build
  end

  # POST /admin/products/1/images
  def create
    @image = @product.images.build(image_params)

    respond_to do |format|
      if @image.save
        format.json { render json: @image, status: 200 }
      else
        format.json { render json: {error: @image.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # PATCH/PUT /admin/images/1
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update(image_params)
        format.js
      end
    end
  end

  # DELETE /admin/images/1
  def destroy
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.destroy
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(
        :image_type_id, :attachment
      )
    end
end
