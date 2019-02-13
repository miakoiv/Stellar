class Admin::ProductPropertiesController < AdminController

  before_action :set_product, only: [:create]

  # POST /admin/products/1/product_properties
  def create
    @product_property = @product.product_properties
      .find_or_initialize_by(product_property_params)
    respond_to do |format|
      if @product_property.save
        track @product_property, @product
        @product.touch
        format.js { render :create }
      else
        format.json { render json: @product_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/product_properties/1
  def destroy
    @product_property = ProductProperty.find(params[:id])
    @product = @product_property.product
    track @product_property, @product

    respond_to do |format|
      if @product.product_properties.destroy(@product_property)
        @product.touch
        format.js
      end
    end
  end

  private
    def set_product
      @product = Product.friendly.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_property_params
      params.require(:product_property).permit(
        :property_id, :value
      )
    end
end
