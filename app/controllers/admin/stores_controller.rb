#encoding: utf-8

class Admin::StoresController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!

  authorize_actions_for Store
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /admin/stores
  # GET /admin/stores.json
  def index
    @stores = Store.all
  end

  # GET /admin/stores/1
  # GET /admin/stores/1.json
  def show
  end

  # GET /admin/stores/new
  def new
    @store = Store.new
  end

  # GET /admin/stores/1/edit
  def edit
  end

  # POST /admin/stores
  # POST /admin/stores.json
  def create
    @store = Store.new(store_params)

    respond_to do |format|
      if @store.save
        format.html { redirect_to admin_store_path(@store),
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
        :contact_person_id, :erp_number, :name, :host, :theme, :locale,
        :admit_guests, :shipping_cost, :free_shipping_at,
        :shipping_cost_product_id
      )
    end
end
