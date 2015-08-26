#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate user, but skip authentication
  # if the current store admits guests.
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

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || current_store.locale || I18n.default_locale
  end

  after_filter :prepare_unobtrusive_flash

  # Select current store by requested hostname, but default to
  # current user's designated store if there is no match.
  def current_store
    Store.find_by(host: request.host) || current_user.store
  end
  helper_method :current_store

  # Find the guest user stored in session, or create it.
  def guest_user
    @cached_guest ||= User.find(session[:guest_user_id] ||= create_guest_user.id)
  end

  private
    def create_guest_user
      guest = User.create(
        store: current_store,
        name: 'Guest',
        email: "guest_#{Time.now.to_i}#{rand(100)}@leasit.info",
        roles: [Role.guest]
      )
      guest.save!(validate: false)
      session[:guest_user_id] = guest.id
      guest
    end

end
