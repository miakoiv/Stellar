#encoding: utf-8

class StoreController < ApplicationController

  def wiselinks_layout
    'application'
  end

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  before_action :set_mail_host
  before_action :set_pricing_group

  # Unauthenticated guests may visit the store.
  before_action :authenticate_user_or_skip!, except: [:index, :show_page]

  before_action :set_header_and_footer
  before_action :set_categories,
    only: [:front, :search, :show_page, :cart, :show_category, :show_promotion, :show_product]
  before_action :find_page, only: [:show_page]
  before_action :find_category, only: [:show_category]
  before_action :find_promotion, only: [:show_promotion]
  before_action :find_product, only: [:show_product]
  before_action :enable_navbar_search,
    only: [:front, :show_category, :show_promotion, :show_product]

  # GET /
  def index
    entry_point = @header.descendants.live.entry_point
    redirect_to entry_point.present? ? entry_point.path : front_path
  end

  # GET /front
  def front
    @category = @live_categories.first_with_products
    if @category.present?
      return redirect_to show_category_path(@category)
    end
  end

  # GET /:slug
  def show_page
  end

  # GET /cart
  def cart
    @order = shopping_cart
    return redirect_to front_path if @order.empty?
  end

  # GET /cart/delete
  def delete_cart
    @order = shopping_cart
    @order.destroy

    redirect_to front_path, notice: t('.notice')
  end

  # GET /store/search
  # GET /store/search.js
  def search
    @query = saved_search_query('product', 'product_search')
    @search = ProductSearch.new(search_params)
    @products = @search.results.visible.page(params[:page])
    @properties = current_store.properties.searchable

    respond_to :js, :html
  end

  # GET /store/lookup.js
  def lookup
    @query = params[:product_search]
    @search = ProductSearch.new(search_params)
    @products = @search.results.visible.limit(Product::INLINE_SEARCH_RESULTS)

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
    @query = params[:product_search] || {}
    @filter_enabled = @query.present?
    @search = ProductSearch.new(filter_params)
    @products = @search.results.visible.sorted(@category.product_scope)
  end

  # GET /promotion/:promotion_id
  def show_promotion
    @products = @promotion.products.visible
  end

  # GET /product/:product_id(/:category_id)
  def show_product
    @category = if params[:category_id].present?
      @live_categories.friendly.find(params[:category_id])
    else
      @product.category
    end
  end

  # POST /product/:product_id/order.js
  def order_product
    @order = shopping_cart
    @product = current_store.products.live.friendly.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert(@product, amount, current_pricing)
    @order.recalculate!

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
    respond_to :js
  end

  private
    def set_mail_host
      ActionMailer::Base.default_url_options = {host: request.host}
    end

    # Find category from live categories by friendly id, including history.
    def find_category
      selected = @live_categories.friendly.find(params[:category_id])
      if params[:product_id].nil? && request.path != show_category_path(selected)
        return redirect_to show_category_path(selected), status: :moved_permanently
      end
      @category = selected.first_with_products
      if @category != selected
        return redirect_to show_category_path(@category)
      end
    end

    # Find promotion from active promotions by friendly id.
    def find_promotion
      @promotion = current_store.promotions.active.friendly.find(params[:promotion_id])
    end

    # Find product by friendly id in `product_id`, redirecting to its
    # first variant if applicable.
    def find_product
      selected = current_store.products.live.friendly.find(params[:product_id])
      @product = selected.first_variant
      if @product != selected
        return redirect_to show_product_path(@product, @category)
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

    # Product filtering in the current category.
    def filter_params
      @query.merge(store_id: current_store.id, live: true, categories: [@category])
    end
end
