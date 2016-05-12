#encoding: utf-8

class Admin::CustomerAssetsController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  authorize_actions_for CustomerAsset
  before_action :set_customer_asset, only: [:show, :edit]

  # GET /admin/customer_assets
  # GET /admin/customer_assets.json
  def index
    @query = saved_search_query('customer_asset', 'admin_customer_asset_search')
    @search = CustomerAssetSearch.new(search_params)
    @customer_assets = @search.results.page(params[:page])
  end

  # GET /admin/customer_assets/1
  def show
  end

  # GET /admin/customer_assets/new
  def new
    @customer_asset = current_store.customer_assets.build
  end

  # GET /admin/customer_assets/1/edit
  def edit
  end

  # POST /admin/customer_assets
  # POST /admin/customer_assets.json
  def create
    @customer_asset = current_store.customer_assets.build(customer_asset_params)

    respond_to do |format|
      if @customer_asset.save
        format.html { redirect_to edit_admin_customer_asset_path(@customer_asset),
          notice: t('.notice', customer_asset: @customer_asset) }
        format.json { render :show, status: :created, location: admin_customer_asset_path(@customer_asset) }
      else
        format.html { render :new }
        format.json { render json: @customer_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_asset
      @customer_asset = current_store.customer_assets.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_asset_params
      params.require(:customer_asset).permit(
        :user_id, :product_id
      )
    end

    # Restrict searching to customer assets in current store.
    def search_params
      @query.merge(
        store_id: current_store.id
      )
    end
end
