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

  before_action :set_categories
  before_action :find_category, only: [:show_category]
  before_action :find_product, only: [:show_product]

  # GET /
  def index
    @category = current_store.categories.ordered.friendly.first
    @products = @category.present? ? @category.products.available.ordered : []
  end

  # GET /category/1
  def show_category
    @products = @category.products.available.ordered
  end

  # GET /product/1
  def show_product
    @category = @product.category
    @products = @category.products.available.ordered
    @presentational_images = @product.images.by_purpose(:presentational).ordered
    @technical_images = @product.images.by_purpose(:technical).ordered
    @documents = @product.images.by_purpose(:document).ordered
  end

  # GET /products/all
  def show_all_products
    @products = current_store.products.available.categorized.ordered
  end

  # POST /product/1/order
  def order_product
    @order = shopping_cart
    @product = Product.available.friendly.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert!(@product, amount)

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
  end

  # GET /cart
  def show_cart
    @order = shopping_cart
  end

  # GET /checkout
  def checkout
    @order = shopping_cart
    if @order.empty?
      return redirect_to show_cart_path
    end
  end

  # POST /confirm
  def confirm
    @order = shopping_cart

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
        format.html { render :checkout }
      end
    end
  end

  private
    def set_categories
      @categories = current_store.categories.top_level.ordered
    end

    # Find category by friendly id in `category_id`, including history.
    def find_category
      @category = Category.friendly.find(params[:category_id])
      if request.path != show_category_path(@category)
        return redirect_to show_category_path(@category), status: :moved_permanently
      end
    end

    # Find product by friendly id in `product_id`, including history.
    def find_product
      @product = Product.available.friendly.find(params[:product_id])
      if request.path != show_product_path(@product)
        return redirect_to show_product_path(@product), status: :moved_permanently
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :shipping_at,
        :customer_name, :customer_email,
        :company_name, :contact_person, :has_billing_address,
        :billing_address, :billing_postalcode, :billing_city,
        :shipping_address, :shipping_postalcode, :shipping_city,
        :notes
      )
    end
end
