#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #---
  prepend_before_action :orientate
  before_action :set_locale
  before_action :set_header_and_footer
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

  # After sign in, users who can manage are taken to the dashboard.
  # Everyone else goes to the default root path. Store admin with
  # pending policies are shown the policies index however.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if can_manage?
        policies_pending? ? admin_policies_url : admin_dashboard_url
      else
        super
      end
  end

  # Send the user back where she came from if not authorized.
  def authority_forbidden(error)
    Rails.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path,
      alert: 'You are not authorized to complete that action.'
  end

  def policies_pending?
    current_user.can_accept?(Policy, at: current_store) && current_store.policies.pending.any?
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

  def current_hostname
    @current_hostname
  end
  helper_method :current_hostname

  def current_store
    @current_store
  end
  helper_method :current_store

  def current_group
    @current_group ||= current_user.group(current_store)
  end
  helper_method :current_group

  def current_site_name
    current_store.present? && current_store.name
  end
  helper_method :current_site_name

  def current_theme
    current_store.present? && current_store.theme
  end
  helper_method :current_theme

  # Selected shopping cart, if any.
  def shopping_cart
    @shopping_cart ||= selected_shopping_cart || user_shopping_cart
  end
  helper_method :shopping_cart

  def user_shopping_cart
    current_user.shopping_cart(current_store, current_hostname.store_portal, current_group)
  end
  helper_method :user_shopping_cart

  # Convenience method to check current user roles at current store.
  def current_user_has_role?(role)
    current_user.has_cached_role?(role, current_store)
  end
  helper_method :current_user_has_role?

  # Belonging to the default group is considered being a guest.
  def guest?
    @guest ||= current_group == current_store.default_group
  end
  helper_method :guest?

  def can_order?
    @can_order = current_user.can?(:order, as: selected_group) if @can_order.nil?
    @can_order
  end
  helper_method :can_order?

  def default_inventory
    current_store.default_inventory
  end
  helper_method :default_inventory

  def pricing_shown?
    selected_group.pricing_shown?
  end
  helper_method :pricing_shown?

  def stock_shown?
    selected_group.stock_shown?
  end
  helper_method :stock_shown?

  # Pricing in views is handled by an appraiser for the selected group.
  def pricing
    @product_appraiser ||= Appraiser::Product.new(selected_group)
  end
  helper_method :pricing

  # Pricing for the premium group of current group, if any.
  def premium_pricing
    return nil if selected_group.premium_group.nil?
    @premium_appraiser ||= Appraiser::Product.new(selected_group.premium_group)
  end
  helper_method :premium_pricing

  # Convenience method to tell if prices in views are with or without tax.
  def incl_tax?
    @tax_included ||= selected_group.price_tax_included?
  end
  helper_method :incl_tax?

  def third_party?
    current_user_has_role?(:third_party)
  end
  helper_method :third_party?

  def can_manage?
    @can_manage ||= Role.administrative.any? { |role|
      current_user_has_role?(role)
    }
  end
  helper_method :can_manage?

  # The ability to shop at any given category depends on possible restricted
  # categories given to the current group. If any category assignments
  # exist, shopping is only allowed in the assigned categories.
  def may_shop_at?(category)
    current_group.categories.empty? || current_group.categories.include?(category)
  end
  helper_method :may_shop_at?

  def admin?
    self.class.parent == Admin
  end
  helper_method :admin?

  def can_select_customer?
    current_user_has_role?(:customer_selection)
  end
  helper_method :can_select_customer?

  def selected_customer
    can_select_customer? && shopping_cart.customer || current_user
  end
  helper_method :selected_customer

  def selected_group
    selected_customer.group(current_store)
  end
  helper_method :selected_group

  # Tracks activity for given resource in given context, with current store
  # and current user. Stores the action taken on given resource, storing any
  # changes made as differences, except changes between two blank values.
  # Options may be supplied to override the recorded action and/or differences.
  def track(resource, context = nil, options = {})
    action = options[:action] || action_name
    differences = options[:differences].presence || resource.previous_changes
      .except('body', 'encrypted_password', 'created_at', 'updated_at')
      .reject { |_, value| value.reject(&:blank?).empty? }

    activity = Activity.create(
      store: current_store,
      user: current_user,
      action: action,
      resource: resource,
      context: context || resource,
      differences: differences
    )
  end

  def not_found
    render nothing: true, status: 404
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
      if !request.xhr? && current_store.present?
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

    # Create a record for a guest user and schedule a cleanup in two weeks.
    def create_guest_user
      guest = User.generate_guest!(current_hostname, current_store.default_group)
      session[:guest_user_id] = guest.id
      GuestCleanupJob.set(wait: 2.weeks).perform_later(guest)
      guest
    end

    def selected_shopping_cart
      can_select_customer? && user_session['shopping_cart_id'].present? && current_user.orders.incomplete.find_by(id: user_session['shopping_cart_id'])
    end
end
