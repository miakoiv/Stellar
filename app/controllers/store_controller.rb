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

  before_action :set_header_and_footer, except: [:show_favorites]
  before_action :set_categories,
    except: [:index, :lookup, :delete_cart, :order_product, :show_favorites]
  before_action :set_departments,
    except: [:index, :lookup, :delete_cart, :order_product, :show_favorites]
  before_action :find_page, only: [:show_page]
  before_action :find_category, only: [:show_category]
  before_action :find_department, only: [:show_department]
  before_action :find_promotion, only: [:show_promotion]
  before_action :find_product, only: [:show_product]

  # GET /
  def index
    if current_store.present?
      entry_point = @header.descendants.live.entry_point
      return redirect_to entry_point.present? ? entry_point.path : front_path
    end
    render :index, layout: 'devise'
  end

  # GET /front
  def front
    @category = @live_categories.first
    if @category.present?
      return redirect_to show_category_path(@category)
    end
  end

  # GET /store/lookup.js
  def lookup
    @query = params
    category_search = CategorySearch.new(category_lookup_params)
    product_search = ProductSearch.new(product_lookup_params)
    @category_results = category_search.results
    @product_results = product_search.results.visible
      .limit(Product::INLINE_SEARCH_RESULTS)
    @results = @category_results.any? || @product_results.any?

    respond_to :js
  end

  # GET /:slug
  def show_page
  end

  # GET /cart
  def cart
    @order = shopping_cart
    @order_types = @order.available_order_types

    render current_store.fancy_cart? ? :fancy_cart : :cart
  end

  # GET /products/promoted/1.js
  def show_promoted_products
    order_types = selected_group.outgoing_order_types
    @products = Product.best_selling(shopping_cart, order_types)

    respond_to :js
  end

  # GET /cart/quote/:recipient
  def quote
    @order = shopping_cart
    @recipient = case params[:recipient]
    when 'self'
      current_user
    when 'customer'
      @order.customer
    else
      return head :bad_request
    end
    @order.email(:quotation, @recipient.to_s)

    flash.now[:notice] = t('.notice', email: @recipient.email)
    respond_to :js
  end

  # GET /cart/delete
  def delete_cart
    @order = shopping_cart
    @order.destroy

    redirect_to cart_path, notice: t('.notice')
  end

  # GET /category/:category_id
  def show_category
    @query = params[:product_search] || {}
    @search = ProductSearch.new(filter_params)
    results = @search.results.visible.sorted(@category.product_scope)
    @products = results.page(params[:page])
    @view_mode = get_view_mode_setting(@category)
  end

  # GET /department/:department_id
  def show_department
    @products = @department.products.live.random.page(params[:page]).per(24)

    respond_to :js, :html
  end

  # GET /promotion/:promotion_id
  def show_promotion
    @products = @promotion.products.visible.page(params[:page])
  end

  # GET /product/:product_id(/:category_id)
  def show_product
    @category ||= if params[:category_id].present?
      @live_categories.friendly.find(params[:category_id])
    else
      @product.category
    end
  end

  # POST /product/:product_id/order.js
  def order_product
    @order = shopping_cart
    @order_types = @order.available_order_types
    @product = current_store.products.live.friendly.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert(@product, amount, @order.source)
    @order.recalculate!

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
    respond_to :js
  end

  # GET /store/favorites.js
  def show_favorites
    @products = current_user.favorite_products
    respond_to :js
  end

  # POST /store/favorites/:product_id.js
  def add_favorite
    @product = current_store.products.live.friendly.find(params[:product_id])
    favorites = current_user.favorite_products
    favorites << @product unless favorites.include?(@product)
    respond_to :js
  end

  # DELETE /store/favorites/:product_id.js
  def remove_favorite
    @product = current_store.products.live.friendly.find(params[:product_id])
    current_user.favorite_products.delete(@product)
    respond_to :js
  end

  # GET /store/favorites/:product_id.json
  def check_favorite
    @product = current_store.products.live.friendly.find(params[:product_id])
    is_favorite = current_user.favorite_products.include?(@product)
    render json: {isFavorite: is_favorite}
  end

  private
    # Find category from live categories by friendly id, including history.
    # If the category contains no products of its own and has no filtering
    # enabled, redirect to the first descendant category.
    def find_category
      @category = @live_categories.friendly.find(params[:category_id])
      if params[:product_id].nil? && request.path != show_category_path(@category)
        return redirect_to show_category_path(@category), status: :moved_permanently
      end
      if @category.products.visible.empty? && !@category.filtering
        if first_child = @category.children.live.first
          return redirect_to show_category_path(first_child)
        end
      end
    end

    # Find department by friendly id in `department_id`, including history.
    def find_department
      @department = @departments.friendly.find(params[:department_id])
      if request.path != show_department_path(@department)
        return redirect_to show_department_path(@department), status: :moved_permanently
      end
    end

    # Find promotion from live promotions by friendly id.
    def find_promotion
      @promotion = current_store.promotions.live.friendly.find(params[:promotion_id])
    end

    # Find product by friendly id in `product_id`, redirecting to its
    # first variant if applicable. If the product is not found, attempt
    # applying an older routing scheme before giving up.
    def find_product
      selected = current_store.products.live.find_by(slug: params[:product_id])
      if selected.nil?
        redirect_old_product_routes and return
        return redirect_to front_path, notice: t('store.product_not_found')
      end
      @product = selected.first_variant
      if @product != selected
        return redirect_to show_product_path(@product, @category)
      end
    end

    # If a product can't be found but category id is given, attempt to
    # redirect with the url params in reverse order as found in older
    # product routes.
    def redirect_old_product_routes
      if params[:category_id].present?
        selected = current_store.products.live.find_by(slug: params[:category_id])
        if selected.present?
          @category = @live_categories.friendly.find(params[:product_id])
          return redirect_to show_product_path(selected, @category)
        end
      end
      false
    end

    # Find page by friendly id in `slug`.
    def find_page
      @page = current_store.pages.friendly.find(params[:slug])
    end

    def get_view_mode_setting(category)
      settings = if cookies[:view_mode_settings].present?
        JSON.parse(cookies[:view_mode_settings])
      else
        {}
      end
      key = ActionView::RecordIdentifier.dom_id(category)
      settings[key] || category.view_mode
    end

    # Category lookup includes categories in current store that are
    # live and have a category page contained in the store header,
    # thus they are navigable.
    def category_lookup_params
      @query.merge(
        store: current_store,
        live: true,
        within: current_store.header
      )
    end

    # Restrict product lookup to live products in current store,
    # or member stores if defined (applies to portals).
    def product_lookup_params
      @query.merge(store: current_store.member_stores.presence || current_store, live: true)
    end

    # Product filtering in the current category asks the category
    # whether to include its descendants in the view.
    def filter_params
      @query.merge(
        store: current_store,
        live: true,
        permitted_categories: @category.self_and_maybe_descendants
      )
    end
end
