#encoding: utf-8

class Admin::InventoriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]

  authorize_actions_for Inventory

  layout 'admin'

  # GET /admin/inventories
  # GET /admin/inventories.json
  def index
    @inventories = current_store.inventories
  end

  # GET /admin/inventories/1
  # GET /admin/inventories/1.json
  def show
  end

  # GET /admin/inventories/new
  def new
    @inventory = current_store.inventories.build
  end

  # GET /admin/inventories/1/edit
  def edit
  end

  # POST /admin/inventories
  # POST /admin/inventories.json
  def create
    @inventory = current_store.inventories.build(inventory_params)

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
