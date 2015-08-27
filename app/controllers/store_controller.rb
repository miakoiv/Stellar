#encoding: utf-8

class StoreController < ApplicationController

  def wiselinks_layout
    'application'
  end

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # Unauthenticated guests may visit the store.
  before_action :authenticate_user_or_skip!

  before_action :set_order
  before_action :set_categories

  # GET /
  def index
    @category = current_store.categories.ordered.first
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
    @presentational_images = @product.images.by_purpose(:presentational).ordered
    @technical_images = @product.images.by_purpose(:technical).ordered
    @documents = @product.images.by_purpose(:document).ordered
  end

  # GET /products/all
  def show_all_products
    @products = current_store.products.categorized.ordered
  end

  # GET /cart
  def show_cart
  end

  # POST /product/1/order
  def order_product
    @product = Product.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert!(@product, amount)

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
  end

  # POST /checkout
  def checkout
    respond_to do |format|
      if @order.update(order_params)
        if @order.has_payment?
          @payment = Payment.new @order,
            ok_url: confirm_order_url(@order),
            error_url: show_cart_url,
            cancel_url: show_cart_url
          format.html { render :confirm }
        else
          @order.update ordered_at: Time.current
          format.html { redirect_to confirm_order_path(@order),
            notice: t('.notice') }
        end
      else
        format.html { render :show_cart }
      end
    end
  end

  private
    # Finds current user's shopping cart, which is technically an order.
    def set_order
      @order = current_user.shopping_cart(current_store)
    end

    def set_categories
      @categories = current_store.categories.ordered
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :shipping_at,
        :company_name, :contact_person, :has_billing_address,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end
end
