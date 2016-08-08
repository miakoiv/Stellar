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
  before_action :set_stores
  before_action :set_departments
  before_action :find_department, only: [:show_department]
  before_action :prepare_search

  # GET /
  def index
  end

  # GET /portal/search
  def search
    @products = @search.results.page(params[:page]).per(30)

    respond_to :js, :html
  end

  # GET /department/:department_id
  def show_department
    @products = @department.all_products.includes(:store).page(params[:page]).per(30)

    respond_to :js, :html
  end

  private

    # Redirect to the storefront if there is no portal here, or a subdomain
    # inside a portal is specified.
    def conditional_redirect_to_storefront
      redirect_to store_path if current_portal.nil? || current_portal.present? && request.subdomain.present?
    end

    def set_locale
      I18n.locale = params[:locale] || current_portal.locale || I18n.default_locale
    end

    def set_stores
      @stores = current_portal.stores
    end

    def set_departments
      @departments = current_portal.departments
    end

    # Find department by friendly id in `department_id`, including history.
    def find_department
      @department = @departments.friendly.find(params[:department_id])
      if request.path != show_department_path(@department)
        return redirect_to show_department_path(@department), status: :moved_permanently
      end
    end

    def prepare_search
      @search = ProductSearch.new(search_params)
    end

    # Restrict searching to live products under current portal.
    def search_params
      @query = params[:search] || {}
      @query.merge(store_id: current_portal.stores, live: true)
    end
end
