#encoding: utf-8

class Admin::StoresController < ApplicationController

  before_action :authenticate_user!
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/stores
  # GET /admin/stores.json
  def index
    authorize_action_for Store, at: current_store
    @query = saved_search_query('store', 'admin_store_search')
    @search = StoreSearch.new(@query)
    @stores = @search.results
  end

  # GET /admin/stores/1
  # GET /admin/stores/1.json
  def show
    authorize_action_for @store, at: current_store
  end

  # GET /admin/stores/new
  def new
    authorize_action_for Store, at: current_store
    @store = Store.new(locale: I18n.default_locale, country: Country.default)
    @store.tax_categories.build
  end

  # GET /admin/stores/1/edit
  def edit
    authorize_action_for @store, at: current_store
  end

  # POST /admin/stores
  # POST /admin/stores.json
  def create
    authorize_action_for Store, at: current_store
    @store = Store.new(store_params.merge(Store.default_settings))

    respond_to do |format|
      if @store.save
        track @store
        format.html { redirect_to edit_admin_store_path(@store),
          notice: t('.notice', store: @store) }
        format.json { render :show, status: :created, location: admin_store_path(@store) }
      else
        format.html { render :new }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    authorize_action_for @store, at: current_store

    respond_to do |format|
      if @store.update(store_params)
        track @store
        format.html { redirect_to admin_store_path(@store),
          notice: t('.notice', store: @store) }
        format.json { render :show, status: :ok, location: admin_store_path(@store) }
      else
        format.html { render :edit }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:store).permit(
        :portal, :name, :locale, :country_code, :shipping_origin,
        :admit_guests, :disable_mail, :disable_shipment_transfers,
        :tracking_code, :maps_api_key,
        :facebook_access_token, :facebook_pixel_id,
        :tawkto_site_id, :pbw_api_key, :pbw_private_key,
        :quotation_template_id,
        :csv_encoding, :csv_product_code,
        :csv_trade_price, :csv_retail_price, :csv_inventory_amount,
        :order_xml_path, :erp_number, :vat_number, :order_sequence,
        :theme, :detach_menu, :fancy_cart, :favorites,
        :masonry, :footer_page_id,
        tax_categories_attributes: [
          :name, :rate, :included_in_retail
        ]
      )
    end
end
