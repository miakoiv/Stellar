#encoding: utf-8

class StoreController < ApplicationController

  def wiselinks_layout
    'application'
  end

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  def current_group
    delegate_group || super
  end

  before_action :set_mail_host

  # Unauthenticated guests may visit the store.
  before_action :authenticate_user_or_skip!, except: [:index, :show_page]

  before_action :set_header_and_footer
  before_action :set_categories,
    except: [:index, :lookup, :delete_cart, :pricing, :order_product]
  before_action :set_departments,
    except: [:index, :lookup, :delete_cart, :pricing, :order_product]
  before_action :find_page, only: [:show_page]
  before_action :find_category, only: [:show_category]
  before_action :find_department, only: [:show_department]
  before_action :find_promotion, only: [:show_promotion]
  before_action :find_product, only: [:show_product]

  # GET /
  def index
    entry_point = @header.descendants.live.entry_point
    redirect_to entry_point.present? ? entry_point.path : front_path
  end

  # GET /front
  def front
    @category = @live_categories.first
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

  # GET /category/:category_id
  def show_category
    @query = params[:product_search] || {}
    @search = ProductSearch.new(filter_params)
    @products = @search.results.visible.sorted(@category.product_scope)
  end

  # GET /department/:department_id
  def show_department
    @products = @department.products.live.random.page(params[:page]).per(24)

    respond_to :js, :html
  end

  # GET /promotion/:promotion_id
  def show_promotion
    @products = @promotion.products.visible
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
    @product = current_store.products.live.friendly.find(params[:product_id])
    amount = params[:amount].to_i
    @order.insert(@product, amount, current_group)
    @order.recalculate!

    flash.now[:notice] = t('.notice', product: @product, amount: amount)
    respond_to :js
  end

  # GET /delegate/:group_id
  def delegate
    @group = current_store.groups.find(params[:group_id])
    if group_delegate? && @group.present? && @group != current_user.group(current_store)
      cookies.signed[:delegate_group_id] = @group.id
      shopping_cart.destroy
      redirect_to store_path, alert: t('.notice', group: @group)
    else
      cookies.delete(:delegate_group_id)
      shopping_cart.destroy
      redirect_to store_path, alert: t('.default')
    end
  end

  private
    def set_mail_host
      ActionMailer::Base.default_url_options = {host: request.host}
    end

    # Find category from live categories by friendly id, including history.
    def find_category
      @category = @live_categories.friendly.find(params[:category_id])
      if params[:product_id].nil? && request.path != show_category_path(@category)
        return redirect_to show_category_path(@category), status: :moved_permanently
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

    # Find page by friendly id in `slug`, including history.
    def find_page
      @page = current_store.pages.friendly.find(params[:slug])
      if request.path != show_page_path(@page)
        return redirect_to show_page_path(@page), status: :moved_permanently
      end
    end

    # Restrict category lookup to live categories in current store.
    def category_lookup_params
      @query.merge(store: current_store, live: true)
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
        live: true
      ).reverse_merge(
        'categories' => @category.self_and_maybe_descendants
      )
    end
end
