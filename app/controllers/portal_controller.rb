#encoding: utf-8
#
# PortalController is the entry point to the app. The current portal is
# selected by matching request.host to a portal domain name.
# Stores participating in the portal live under subdomains of that domain.
#
class PortalController < ApplicationController

  layout 'portal'

  before_action :conditional_redirect_to_storefront
  before_action :set_locale

  # GET /
  def index
  end

  private

    # Redirect to the storefront if there is no portal here, or a subdomain
    # inside a portal is specified.
    def conditional_redirect_to_storefront
      redirect_to front_path if current_portal.nil? || current_portal.present? && request.subdomain.present?
    end

    def set_locale
      I18n.locale = params[:locale] || current_portal.locale || I18n.default_locale
    end
end
