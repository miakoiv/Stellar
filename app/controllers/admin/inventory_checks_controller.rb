#encoding: utf-8

class Admin::InventoryChecksController < ApplicationController

  before_action :authenticate_user!
  before_action :set_inventory_check, except: [:index, :new, :create]

  authority_actions complete: 'update', resolve: 'update', conclude: 'update'

  layout 'admin'

  # GET /admin/inventory_checks
  def index
    authorize_action_for InventoryCheck, at: current_store
    query = saved_search_query('inventory_check', 'admin_inventory_check_search')
    @search = InventoryCheckSearch.new(query.merge(search_params))
    results = @search.results
    @inventory_checks = results.page(params[:page])
  end

  # GET /admin/inventory_checks/1
  def show
    authorize_action_for @inventory_check, at: current_store
  end

  # GET /admin/inventory_checks/new
  def new
    authorize_action_for InventoryCheck, at: current_store
    @inventory_check = current_store.inventory_checks.build
  end

  # GET /admin/inventory_checks/1/edit
  def edit
    authorize_action_for @inventory_check, at: current_store
  end

  # POST /admin/inventory_checks
  # POST /admin/inventory_checks.json
  def create
    authorize_action_for InventoryCheck, at: current_store
    @inventory_check = current_store.inventory_checks.build(inventory_check_params)

    respond_to do |format|
      if @inventory_check.save
        track @inventory_check
        format.html { redirect_to edit_admin_inventory_check_path(@inventory_check),
          notice: t('.notice', inventory_check: @inventory_check) }
        format.json { render :show, status: :created, location: admin_inventory_check_path(@inventory_check) }
      else
        format.html { render :new }
        format.json { render json: @inventory_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/inventory_checks/1
  # PATCH/PUT /admin/inventory_checks/1.json
  def update
    authorize_action_for @inventory_check, at: current_store

    respond_to do |format|
      if @inventory_check.update(inventory_check_params)
        track @inventory_check
        format.html { redirect_to admin_inventory_check_path(@inventory_check),
          notice: t('.notice', inventory_check: @inventory_check) }
        format.json { render :show, status: :ok, location: admin_inventory_check_path(@inventory_check) }
      else
        format.html { render :edit }
        format.json { render json: @inventory_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/inventory_checks/1
  # DELETE /admin/inventory_checks/1.json
  def destroy
    authorize_action_for @inventory_check, at: current_store
    track @inventory_check
    @inventory_check.destroy

    respond_to do |format|
      format.html { redirect_to admin_inventory_checks_path,
        notice: t('.notice', inventory_check: @inventory_check) }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /admin/inventory_checks/1/complete
  def complete
    authorize_action_for @inventory_check, at: current_store

    respond_to do |format|
      if @inventory_check.complete!
        track @inventory_check
        format.html { redirect_to resolve_admin_inventory_check_path(@inventory_check), notice: t('.notice', inventory_check: @inventory_check) }
      else
        format.html { render :show }
      end
    end
  end

  # GET /admin/inventory_checks/1/resolve
  def resolve
  end

  # PATCH/PUT /admin/inventory_checks/1/conclude
  def conclude
    authorize_action_for @inventory_check, at: current_store

    respond_to do |format|
      if @inventory_check.conclude!
        track @inventory_check
        format.html { redirect_to admin_inventory_check_path(@inventory_check), notice: t('.notice', inventory_check: @inventory_check) }
      else
        format.html { render :show }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_check
      @inventory_check = current_store.inventory_checks.find(params[:id])
    end

    def inventory_check_params
      params.require(:inventory_check).permit(
        :inventory_id, :note
      )
    end

    def search_params
      {
        store: current_store
      }
    end
end
