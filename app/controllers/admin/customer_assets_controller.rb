class Admin::CustomerAssetsController < AdminController

  before_action :set_customer_asset, only: [:show, :edit]

  # GET /admin/customer_assets
  # GET /admin/customer_assets.json
  def index
    authorize_action_for CustomerAsset, at: current_store
    query = saved_search_query('customer_asset', 'admin_customer_asset_search')
    @search = CustomerAssetSearch.new(query.merge(search_constrains))
    @customer_assets = @search.results.page(params[:page])
  end

  # GET /admin/customer_assets/1
  def show
    authorize_action_for @customer_asset, at: current_store
  end

  # GET /admin/customer_assets/new
  def new
    authorize_action_for CustomerAsset, at: current_store
    @customer_asset = current_store.customer_assets.build
    track @customer_asset
  end

  # GET /admin/customer_assets/1/edit
  def edit
    authorize_action_for @customer_asset, at: current_store
  end

  # POST /admin/customer_assets
  # POST /admin/customer_assets.json
  def create
    authorize_action_for CustomerAsset, at: current_store
    @customer_asset = current_store.customer_assets.build(customer_asset_params)

    respond_to do |format|
      if @customer_asset.save
        track @customer_asset
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
    def search_constrains
      {store: current_store}
    end
end
