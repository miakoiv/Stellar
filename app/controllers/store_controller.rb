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
  before_action :authenticate_user_or_skip!, except: [:index, :show_page]

  before_action :set_pages
  before_action :set_categories, only: [:front, :search, :show_category, :show_product]
  before_action :find_page, only: [:show_page]
  before_action :find_category, only: [:show_category, :show_product]
  before_action :find_product, only: [:show_product]
  before_action :enable_navbar_search, only: [:front, :show_category, :show_product]

  # GET /
  def index
    redirect_to @pages.any? ? show_page_path(@pages.first) : front_path
  end

  # GET /front
  def front
    @category = @categories.first.try(:having_products)
    @products = @category.present? ? @category.products.live.on_display.sorted(@category.product_scope) : []
  end

  # GET /:slug
  def show_page
  end

  # GET /cart
  def cart
    @order = shopping_cart
    return redirect_to store_path if @order.empty?
  end

  # GET /cart/delete
  def delete_cart
    @order = shopping_cart
    @order.destroy

    redirect_to store_path, notice: t('.notice')
  end

  # GET /store/search
  def search
    @query = saved_search_query('product', 'product_search')
    @search = ProductSearch.new(search_params)
    @products = @search.results.page(params[:page])
    @properties = current_store.properties.searchable

    respond_to :js, :html
  end

  # GET /store/lookup
  def lookup
    @query = params[:product_search]
    @search = ProductSearch.new(search_params)
    @products = @search.results.limit(Product::INLINE_SEARCH_RESULTS)

    respond_to :js
  end

  # GET /store/pricing/(:pricing_group_id)
  def pricing
    pricing_group_id = params[:pricing_group_id]
    cookies[:pricing_group_id] = pricing_group_id

    @pricing_group = current_store.pricing_groups.find_by(id: pricing_group_id)
    shopping_cart.reappraise!(@pricing_group)

    redirect_to store_path, alert: t('.alert', pricing: @pricing_group.try(:name) || t('store.pricing_groups.default'))
  end

  # GET /category/:category_id
  def show_category
    display_products = @category.products.live.on_display
    @products = display_products.sorted(@category.product_scope)
  end

  # GET /product/:category_id/:product_id
  def show_product
  end

  # POST /product/1/order
  def order_product
    @order = shopping_cart
    @product = current_store.products.live.friendly.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert(@product, amount, current_pricing)
    @order.recalculate!

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
  end

  private
    def set_categories
      @live_categories = current_store.categories.live
      @categories = @live_categories.top_level.sorted
    end

    # Find category from live categories by friendly id, including history.
    def find_category
      selected = @live_categories.friendly.find(params[:category_id])
      if params[:product_id].nil? && request.path != show_category_path(selected)
        return redirect_to show_category_path(selected), status: :moved_permanently
      end
      @category = selected.having_products
      if @category != selected
        return redirect_to show_category_path(@category)
      end
    end

    # Find product by friendly id in `product_id`, including history.
    def find_product
      selected = current_store.products.live.friendly.find(params[:product_id])
      if request.path != show_product_path(@category, selected)
        return redirect_to show_product_path(@category, selected), status: :moved_permanently
      end
      @product = selected.first_variant(@category)
      if @product != selected
        return redirect_to show_product_path(@category, @product)
      end
    end

    # Find page by friendly id in `slug`, including history.
    def find_page
      @page = current_store.pages.friendly.find(params[:slug])
      if request.path != show_page_path(@page)
        return redirect_to show_page_path(@page), status: :moved_permanently
      end
    end

    # Enable navbar search widget when applicable.
    def enable_navbar_search
      @navbar_search = true
    end

    # Restrict searching to live products in current store.
    def search_params
      @query.merge(store_id: current_store.id, live: true)
    end
end
