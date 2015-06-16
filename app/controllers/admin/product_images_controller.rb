#encoding: utf-8

class Admin::ProductImagesController < ApplicationController
  before_action :set_product, only: [:new, :create]

  # GET /admin/products/1/product_images/new
  def new
    @product_image = @product.product_images.build
  end

  # POST /admin/products/1/product_images
  def create
    @product_image = @product.product_images.build(product_image_params)

    respond_to do |format|
      if @product_image.save
        format.json { render json: {message: 'success'}, status: 200 }
      else
        format.json { render json: {error: @product_image.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_image_params
      params.require(:product_image).permit(
        :image
      )
    end
end
