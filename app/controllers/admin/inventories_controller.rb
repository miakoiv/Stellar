#encoding: utf-8

class Admin::InventoriesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]

  authority_actions reorder: 'update'

  layout 'admin'

  # GET /admin/inventories
  # GET /admin/inventories.json
  def index
    authorize_action_for Inventory, at: current_store
    @inventories = current_store.inventories
  end

  # GET /admin/inventories/1
  # GET /admin/inventories/1.json
  def show
    authorize_action_for @inventory, at: current_store
  end

  # GET /admin/inventories/new
  def new
    authorize_action_for Inventory, at: current_store
    @inventory = current_store.inventories.build
  end

  # GET /admin/inventories/1/edit
  def edit
    authorize_action_for @inventory, at: current_store
  end

  # POST /admin/inventories
  # POST /admin/inventories.json
  def create
    authorize_action_for Inventory, at: current_store
    @inventory = current_store.inventories.build(inventory_params.merge(priority: current_store.inventories.count))

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to admin_inventory_path(@inventory),
          notice: t('.notice', inventory: @inventory) }
        format.json { render :show, status: :created, location: admin_inventory_path(@inventory) }
      else
        format.html { render :new }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/inventories/1
  # PATCH/PUT /admin/inventories/1.json
  def update
    authorize_action_for @inventory, at: current_store

    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to admin_inventory_path(@inventory),
          notice: t('.notice', inventory: @inventory) }
        format.json { render :show, status: :ok, location: admin_inventory_path(@inventory) }
      else
        format.html { render :edit }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/inventories/1
  # DELETE /admin/inventories/1.json
  def destroy
    authorize_action_for @inventory, at: current_store
    @inventory.destroy

    respond_to do |format|
      format.html { redirect_to admin_inventories_path,
        notice: t('.notice', inventory: @inventory) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = current_store.inventories.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
      params.require(:inventory).permit(
        :fuzzy, :name, :inventory_code
      )
    end
end
