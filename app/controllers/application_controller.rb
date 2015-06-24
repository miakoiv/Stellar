#encoding: utf-8

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate every action.
  before_action :authenticate_user!

  # Find the current brand for the storefront section
  # that is restricted to a single brand.
  def current_brand
    if params[:brand_id].present? # and admin?
      session[:brand_id] = params[:brand_id]
    end
    if session[:brand_id].present?
      Brand.find(session[:brand_id])
    else
      current_user.brand
    end
  end
  helper_method :current_brand
end
