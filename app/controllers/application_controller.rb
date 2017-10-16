#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #---
  prepend_before_action :orientate
  before_action :set_locale
  after_action :prepare_unobtrusive_flash

  #---
  # Before doing anything else, set current hostname and current store
  # based on request.host.
  def orientate
    @current_hostname = Hostname.find_by(fqdn: request.host)
    return render nothing: true, status: :bad_request if @current_hostname.nil?
    @current_store = @current_hostname.store
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

  # Preserves search query params in a cookie, tagged by user id
  # to prevent params from propagating to another user if logged
  # on from the same client.
  def saved_search_query(search_model, query_key)
    param = "#{search_model}_search"
    cookie_key = "#{query_key}_#{current_user.id}"
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
  helper_method :current_hostname, :current_store, :current_group, :current_site_name, :current_theme, :current_pricing, :shopping_cart, :current_user_has_role?, :can_shop?, :can_see_pricing?, :can_see_stock?, :third_party?, :can_manage?, :may_shop_at?

  def current_hostname
    @current_hostname
  end

  def current_store
    @current_store
  end

  def current_group
    @current_group ||= current_user.group(@current_store)
  end

  def current_site_name
    @current_store.present? && @current_store.name
  end

  def current_theme
    @current_store.present? && @current_store.theme
  end

  def current_pricing
    @pricing_group
  end

  def shopping_cart
    @shopping_cart ||= current_user.shopping_cart(@current_store)
  end

  # Convenience method to check current user roles at current store.
  def current_user_has_role?(role)
    current_user.has_cached_role?(role, @current_store)
  end

  def can_shop?
    @can_shop = current_user.can?(:shop, at: @current_store) if @can_shop.nil?
    @can_shop
  end

  def can_see_pricing?
    current_user_has_role?(:see_pricing)
  end

  def can_see_stock?
    current_user_has_role?(:see_stock)
  end

  def third_party?
    current_user_has_role?(:third_party)
  end

  def can_manage?
    @can_manage ||= Role.administrative.any? { |role|
      current_user_has_role?(role)
    }
  end

  # The ability to shop at any given category depends on possible restricted
  # categories given to the current group. If any category assignments
  # exist, shopping is only allowed in the assigned categories.
  def may_shop_at?(category)
    current_group.categories.empty? || current_group.categories.include?(category)
  end

  private

    # Unless given by param, locale is set from user preference first, then
    # from portal settings if any, and finally from store settings.
    def set_locale
      I18n.locale = params[:locale] || user_signed_in? && current_user.locale.presence || @current_store.locale || I18n.default_locale
    end

    def set_header_and_footer
      @header = @current_store.header
      @footer = @current_store.footer
    end

    def set_categories
      @live_categories = @current_store.categories.live.order(:lft)
      @categories = @live_categories.roots
    end

    def set_departments
      @departments = @current_store.departments
    end

    # Pricing group is set by a before_action. Changing the pricing group
    # is done by StoreController#pricing and its id is retained in a cookie.
    # If current user has her own pricing group set, it will take precedence.
    def set_pricing_group
      if user_signed_in? && current_user.pricing_group(@current_store).present?
        @pricing_group = current_user.pricing_group(@current_store)
      else
        pricing_group_id = cookies[:pricing_group_id]
        @pricing_group = @current_store.pricing_groups.find_by(id: pricing_group_id)
      end
    end

    # Create a record for a guest user, put her in the default group,
    # grant her the baseline roles, and schedule a cleanup in two weeks.
    def create_guest_user
      defaults = @current_store.guest_user_defaults(@current_hostname)
      guest = User.new(defaults.merge(store: @current_store))
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      guest.groups << @current_store.default_group
      guest.grant(:see_pricing, @current_store)
      guest.grant(:see_stock, @current_store)
      GuestCleanupJob.set(wait: 2.weeks).perform_later(guest)
      guest
    end
end
