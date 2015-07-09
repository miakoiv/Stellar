#encoding: utf-8

class StoreController < ApplicationController

  def wiselinks_layout
    'application'
  end

  before_action :set_categories

  # GET /
  def index
    @category = current_store.categories.first
    @products = @category.try(:products) || []
  end

  # GET /category/1
  def show_category
    @category = Category.find(params[:category_id])
    @products = @category.products
  end

  # GET /product/1
  def show_product
    @product = Product.find(params[:product_id])
    @category = @product.category
    @products = @category.products
    @presentational_images = @product.images.by_purpose(:presentational)
    @technical_images = @product.images.by_purpose(:technical)
    @documents = @product.images.by_purpose(:document)
  end

  # GET /cart
  def show_cart
    @order = current_user.shopping_cart
  end

  # POST /product/1/order
  def order_product
    @product = Product.find(params[:product_id])
    amount = params[:amount].to_i
    current_user.shopping_cart.insert!(@product, amount)

    flash.now[:notice] = "#{amount} of #{@product} added to cart"
  end

  # POST /checkout
  def checkout
    @order = current_user.shopping_cart
    @order.ordered_at = Time.current

    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to orders_path, notice: 'Order was successfully placed.' }
      else
        format.html { render :show_cart }
      end
    end
  end

  private
    def set_categories
      @categories = current_store.categories
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id
      )
    end
end
