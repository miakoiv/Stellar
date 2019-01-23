#encoding: utf-8

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

  # No current store. BaseStoreController overrides this.
  def current_store
    nil
  end
  helper_method :current_store

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
