#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Send the user back where she came from if not authorized.
  def authority_forbidden(error)
    Rails.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path,
      alert: 'You are not authorized to complete that action.'
  end

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || current_store.locale || I18n.default_locale
  end

  after_filter :prepare_unobtrusive_flash

  # Find the current store for the storefront section.
  def current_store
    if current_user
      # Site staff may use the `store_id` param to switch between stores.
      if current_user.is_site_manager? || current_user.is_site_monitor?
        if params[:store_id].present?
          session[:store_id] = params[:store_id]
        end
        if session[:store_id].present?
          return Store.find(session[:store_id])
        end
      end
      # Everyone else is shackled to their designated store.
      current_user.store
    else
      default_store
    end
  end
  helper_method :current_store

  # Default to finding the store by hostname if possible.
  def default_store
    Store.find_by(host: request.host) || Store.first
  end

  # Find the guest user stored in session, or create it.
  def guest_user
    @cached_guest ||= User.find(session[:guest_user_id] ||= create_guest_user.id)
  end

  private
    def create_guest_user
      guest = User.create(
        store: default_store,
        name: "Guest at #{default_store.name}",
        email: "guest_#{Time.now.to_i}#{rand(100)}@leasit.info",
        roles: [Role.guest]
      )
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      guest
    end

end
