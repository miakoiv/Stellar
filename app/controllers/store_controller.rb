#encoding: utf-8

class StoreController < ApplicationController

  def wiselinks_layout
    'application'
  end
  before_action :authenticate_user!
  before_action :set_categories

  # GET /
  def index
    @category = current_store.categories.first
    @products = @category.present? ? @category.products.ordered : []
  end

  # GET /category/1
  def show_category
    @category = Category.find(params[:category_id])
    @products = @category.products.ordered
  end

  # GET /product/1
  def show_product
    @product = Product.find(params[:product_id])
    @category = @product.category
    @products = @category.products.ordered
    @presentational_images = @product.images.by_purpose(:presentational)
    @technical_images = @product.images.by_purpose(:technical)
    @documents = @product.images.by_purpose(:document)
  end

  # GET /cart
  def show_cart
    @order = current_user.shopping_cart(current_store)
  end

  # POST /product/1/order
  def order_product
    @product = Product.find(params[:product_id])
    amount = params[:amount].to_i
    current_user.shopping_cart(current_store).insert!(@product, amount)

    flash.now[:notice] = "#{amount} of #{@product} added to cart"
  end

  # POST /checkout
  def checkout
    @order = current_user.shopping_cart(current_store)

    respond_to do |format|
      if @order.update(order_params)
        if @order.has_payment?
          @payment = Payment.new @order,
            ok_url: orders_url(anchor: 'ok'),
            error_url: show_cart_url(anchor: 'error'),
            cancel_url: show_cart_url(anchor: 'cancel')
          format.html { render :confirm }
        else
          @order.update ordered_at: Time.current
          format.html { redirect_to orders_path, notice: 'Order was successfully placed.' }
        end
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
        :order_type_id, :shipping_at,
        :company_name, :contact_person, :billing_address, :billing_postalcode,
        :billing_city, :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end
end
