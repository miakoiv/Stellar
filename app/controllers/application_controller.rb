#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #---
  prepend_before_action :set_current_portal_and_store
  after_action :prepare_unobtrusive_flash

  #---
  # Before doing anything else, set current_store, current_portal,
  # or both based on request.host and request.domain.
  def set_current_portal_and_store
    hostname = Hostname.find_by(fqdn: request.host)
    resource = hostname.resource
    if resource.is_a?(Portal)
      @current_portal = resource
    else
      @current_store = resource
      if hostname.is_subdomain?
        domain = Hostname.find_by(fqdn: request.domain)
        @current_portal = domain.resource
      end
    end
  end

  # Authenticate user, but skip authentication if guests are admitted.
  # This method is the first before_action callback in controllers that
  # optionally serve guests, and will fail early if the current store
  # can't be found.
  def authenticate_user_or_skip!
    return true if @current_store.admit_guests?
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
    @cached_guest ||= User.find(session[:guest_user_id]) rescue User.find(session[:guest_user_id] = create_guest_user.id)
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
    @current_portal
  end

  def current_store
    @current_store
  end

  def current_site_name
    @current_store.present? && @current_store.name || @current_portal.name
  end

  def current_theme
    @current_store.present? && @current_store.theme || @current_portal.theme
  end

  def standalone_store?
    @current_portal.nil?
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
      I18n.locale = params[:locale] || user_signed_in? && current_user.locale.presence || @current_portal.present? && @current_portal.locale || @current_store.locale || I18n.default_locale
    end

    def set_pages
      @pages = @current_store.pages
    end

    # Pricing group is set by a before_action. Changing the pricing group
    # is done by StoreController#pricing and its id is retained in a cookie.
    # If current user has her own pricing group set, it will take precedence.
    def set_pricing_group
      if user_signed_in? && current_user.pricing_group.present?
        @pricing_group = current_user.pricing_group
      else
        pricing_group_id = cookies[:pricing_group_id]
        @pricing_group = @current_store.pricing_groups.find_by(id: pricing_group_id)
      end
    end

    # Create a record for a guest user and schedule its cleanup
    # to happen after two weeks.
    def create_guest_user
      guest = @current_store.users.new(@current_store.guest_user_defaults(request.host))
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      GuestCleanupJob.set(wait: 2.weeks).perform_later(guest)
      guest
    end
end
