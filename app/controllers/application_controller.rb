#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate every action.
  before_action :authenticate_user!

  # Send the user back where she came from if not authorized.
  def authority_forbidden(error)
    Rails.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path,
      alert: 'You are not authorized to complete that action.'
  end

  after_filter :prepare_unobtrusive_flash

  # Find the current store for the storefront section
  # that is restricted to a single store.
  def current_store
    if current_user.is_site_manager? || current_user.is_site_monitor?
      if params[:store_id].present?
        session[:store_id] = params[:store_id]
      end
      if session[:store_id].present?
        return Store.find(session[:store_id])
      end
    end
    current_user.store
  end
  helper_method :current_store
end
