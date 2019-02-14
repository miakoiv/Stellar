#
# ApplicationController provides the minimal set of features
# for other controllers to extend, such as BaseStoreController
# and AccountController. Within this controller, current store
# is unset and we're operating outside of any particular store.
#
class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #---
  before_action :set_locale
  after_action :prepare_unobtrusive_flash

  #---
  # Send the user back where she came from if not authorized.
  def authority_forbidden(error)
    Rails.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path,
      alert: 'You are not authorized to complete that action.'
  end

  # Preserves search query params in a cookie, tagged by user id
  # to prevent params from propagating to another user if logged
  # on from the same client.
  def saved_search_query(search_model, query_key)
    param_name = "#{search_model}_search"
    cookie_key = "#{query_key}_#{current_user.id}"
    value = params.fetch(param_name, {})
    if value.empty?
      ActionController::Parameters.new(cookies.signed[cookie_key] || {})
    else
      cookies.signed[cookie_key] = {
        value: value,
        expires: 2.weeks.from_now
      }
      value
    end
  end

  # No current store. BaseStoreController overrides this.
  def current_store
    nil
  end
  helper_method :current_store

  def current_site_name
    'Stellar'
  end
  helper_method :current_site_name

  private

    # Unless given by param, locale is set from user preference first, then
    # from portal settings if any, and finally from store settings.
    def set_locale
      I18n.locale = params[:locale] ||
        user_signed_in? && current_user.locale.presence ||
        current_store.present? && current_store.locale ||
        I18n.default_locale
    end
end
