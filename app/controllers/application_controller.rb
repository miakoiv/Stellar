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
  # based on request.host. Unknown hosts trigger a bad request response
  # except for the default url host, which can be used with Devise without
  # current store.
  def orientate
    @current_hostname = Hostname.find_by(fqdn: request.host)
    if @current_hostname.present?
      @current_store = @current_hostname.store
    else
      unless request.host == ENV['DEFAULT_URL_HOST']
        render nothing: true, status: :bad_request
      end
      @current_store = nil
    end
  end

  # Authenticate user, but skip authentication if guests are admitted.
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
    return nil if current_store.nil?
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
  helper_method :current_hostname, :current_store, :current_group, :current_inventory, :current_site_name, :current_theme, :shopping_cart, :current_user_has_role?, :guest?, :can_order?, :pricing_shown?, :pricing, :incl_tax?, :stock_shown?, :third_party?, :group_delegate?, :can_manage?, :may_shop_at?

  def current_hostname
    @current_hostname
  end

  def current_store
    @current_store
  end

  def current_group
    @current_group ||= current_user.group(current_store)
  end

  # For now, current inventory is always the primary one.
  def current_inventory
    @current_inventory ||= current_store.inventories.first
  end

  def current_site_name
    current_store.present? && current_store.name
  end

  def current_theme
    current_store.present? && current_store.theme
  end

  def shopping_cart
    @shopping_cart ||= current_user.shopping_cart(current_store, current_group)
  end

  # Convenience method to check current user roles at current store.
  def current_user_has_role?(role)
    current_user.has_cached_role?(role, current_store)
  end

  # Belonging to the default group is considered being a guest.
  def guest?
    @guest ||= current_group == current_store.default_group
  end

  def can_order?
    @can_order = current_user.can?(:order, as: current_group) if @can_order.nil?
    @can_order
  end

  def pricing_shown?
    current_group.pricing_shown?
  end

  def stock_shown?
    current_group.stock_shown?
  end

  # Pricing currently in effect is handled by appraisers
  # initialized with the current group.
  def pricing
    @product_appraiser ||= Appraiser::Product.new(current_group)
  end

  # Convenience method to tell if the current group sees prices
  # with or without tax.
  def incl_tax?
    @tax_included ||= current_group.price_tax_included?
  end

  def third_party?
    current_user_has_role?(:third_party)
  end

  def group_delegate?
    current_user_has_role?(:group_delegate)
  end

  def delegate_group
    group_id = cookies.signed[:delegate_group_id]
    group_delegate? && current_store.groups.find_by(id: group_id)
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
      I18n.locale = params[:locale] ||
        user_signed_in? && current_user.locale.presence ||
        current_store.present? && current_store.locale ||
        I18n.default_locale
    end

    def set_header_and_footer
      if current_store.present?
        @header = current_store.header
        @footer = current_store.footer
      end
    end

    def set_categories
      @live_categories = current_store.categories.live.order(:lft)
      @categories = @live_categories.roots
    end

    def set_departments
      @departments = current_store.departments
    end

    # Create a record for a guest user, put her in the default group,
    # grant her the baseline roles, and schedule a cleanup in two weeks.
    def create_guest_user
      defaults = current_store.guest_user_defaults(current_hostname)
      guest = User.new(defaults)
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      guest.groups << current_store.default_group
      GuestCleanupJob.set(wait: 2.weeks).perform_later(guest)
      guest
    end
end
