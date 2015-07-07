#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate every action.
  before_action :authenticate_user!

  after_filter :prepare_unobtrusive_flash

  # Find the current store for the storefront section
  # that is restricted to a single store.
  def current_store
    if params[:store_id].present? # and admin?
      session[:store_id] = params[:store_id]
    end
    if session[:store_id].present?
      Store.find(session[:store_id])
    else
      current_user.store
    end
  end
  helper_method :current_store
end
