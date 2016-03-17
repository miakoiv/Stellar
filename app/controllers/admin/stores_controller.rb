#encoding: utf-8

class Admin::StoresController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  authorize_actions_for Store, except: [:show, :edit, :update]
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /admin/stores
  # GET /admin/stores.json
  def index
    @stores = Store.all
  end

  # GET /admin/stores/1
  # GET /admin/stores/1.json
  def show
    authorize_action_for @store
  end

  # GET /admin/stores/new
  def new
    @store = Store.new
    @store.users.build(roles: Role.where(name: 'superuser'))
  end

  # GET /admin/stores/1/edit
  def edit
    authorize_action_for @store
  end

  # POST /admin/stores
  # POST /admin/stores.json
  def create
    @store = Store.new(store_params.merge(Store.default_settings))

    respond_to do |format|
      if @store.save
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
    authorize_action_for @store

    respond_to do |format|
      if @store.update(store_params)
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
        :host, :erp_number, :name, :theme, :locale, :brand_image,
        :card_image_type, :list_image_type,
        :allow_shopping, :admit_guests,
        :shipping_cost_product_id, :free_shipping_at,
        :manufacturer_letterhead_id, :reseller_letterhead_id,
        :quotation_letterhead_id,
        :tracking_code, inventory_ids: [],
        users_attributes: [
          :name, :email, :phone, :locale, :pricing_factor,
          :password, :password_confirmation, :group, role_ids: []
        ]
      )
    end
end
