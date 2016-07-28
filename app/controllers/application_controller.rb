#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #---
  before_action :set_locale
  after_filter :prepare_unobtrusive_flash

  #---
  # Authenticate user, but skip authentication if guests are admitted.
  # This method is the first before_action callback in controllers that
  # optionally serve guests, and will fail early if the current store
  # can't be found.
  def authenticate_user_or_skip!
    return true if current_store.admit_guests?
    authenticate_user!
  end

  # Send the user back where she came from if not authorized.
  def authority_forbidden(error)
    Rails.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path,
      alert: 'You are not authorized to complete that action.'
  end

  # Find the guest user stored in session, or create it.
  def guest_user
    @cached_guest ||= User.find(session[:guest_user_id] ||= create_guest_user.id)
  end

  # Preserves search query param in a cookie.
  def saved_search_query(search_model, cookie_key)
    param = "#{search_model}_search"
    if params[param]
      cookies[cookie_key] = {
        value: params[param].to_json,
        expires: 2.weeks.from_now
      }
    end
    params[param].presence || JSON.load(cookies[cookie_key]) || {}
  end

  # The methods below are for convenience and to cache often repeated
  # database queries on current user and her roles.
  helper_method :current_portal, :current_store, :current_site_name, :current_theme, :standalone_store?, :current_pricing, :shopping_cart, :can_shop?, :can_see_pricing?, :can_see_stock?, :can_manage?, :may_shop_at?

  def current_portal
    @current_portal ||= current_portal_by_request
  end

  def current_store
    @current_store ||= user_signed_in? && current_user.store || current_store_by_request
  end

  def current_site_name
    current_store.present? ? current_store.name : current_portal.name
  end

  def current_theme
    current_store.present? ? current_store.theme : current_portal.theme
  end

  def standalone_store?
    current_portal.nil?
  end

  def current_pricing
    @pricing_group
  end

  def shopping_cart
    @shopping_cart ||= current_user.shopping_cart
  end

  def can_shop?
    @can_shop = current_user.can?(:shop, store: current_store) if @can_shop.nil?
    @can_shop
  end

  def can_see_pricing?
    current_user.has_cached_role?(:see_pricing)
  end

  def can_see_stock?
    current_user.has_cached_role?(:see_stock)
  end

  def can_manage?
    current_user.has_cached_role?(:manager)
  end

  # The ability to shop at any given category depends on possible restricted
  # categories given to the current user. If any category assignments
  # exist, shopping is only allowed in the assigned categories.
  def may_shop_at?(category)
    current_user.categories.empty? || current_user.categories.include?(category)
  end

  private

    # Unless given by param, locale is set from user preference first, then
    # from portal settings if any, and finally from store settings.
    def set_locale
      I18n.locale = params[:locale] || user_signed_in? && current_user.locale.presence || current_portal.present? && current_portal.locale || current_store.locale || I18n.default_locale
    end

    def set_pages
      @pages = current_store.pages.includes(:sub_pages)
    end

    # Finds the current portal by requested domain, if any.
    def current_portal_by_request
      Portal.find_by(domain: request.domain)
    end

    # Finds the current store by requested host. If inside a portal,
    # the requested subdomain is matched instead, yielding nil if the address
    # contains no subdomain part.
    def current_store_by_request
      if current_portal.present?
        current_portal.stores.find_by(subdomain: request.subdomain)
      else
        Store.find_by!(host: request.host)
      end
    end

    # Create a record for a guest user and schedule its cleanup
    # to happen after two weeks.
    def create_guest_user
      store = current_store_by_request
      guest = store.users.new(store.guest_user_defaults)
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      GuestCleanupJob.set(wait: 2.weeks).perform_later(guest)
      guest
    end
end
