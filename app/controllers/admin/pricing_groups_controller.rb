#encoding: utf-8

class Admin::PricingGroupsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_pricing_group, only: [:show, :edit, :update, :destroy]

  authorize_actions_for PricingGroup

  layout 'admin'

  # GET /admin/pricing_groups
  # GET /admin/pricing_groups.json
  def index
    @pricing_groups = current_store.pricing_groups
  end

  # GET /admin/pricing_groups/1
  # GET /admin/pricing_groups/1.json
  def show
  end

  # GET /admin/pricing_groups/new
  def new
    @pricing_group = current_store.pricing_groups.build
  end

  # GET /admin/pricing_groups/1/edit
  def edit
  end

  # POST /admin/pricing_groups
  # POST /admin/pricing_groups.json
  def create
    @pricing_group = current_store.pricing_groups.build(pricing_group_params)

    respond_to do |format|
      if @pricing_group.save
        format.html { redirect_to admin_pricing_group_path(@pricing_group),
          notice: t('.notice', pricing_group: @pricing_group) }
        format.json { render :show, status: :created, location: admin_pricing_group_path(@pricing_group) }
      else
        format.html { render :new }
        format.json { render json: @pricing_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/pricing_groups/1
  # PATCH/PUT /admin/pricing_groups/1.json
  def update
    respond_to do |format|
      if @pricing_group.update(pricing_group_params)
        format.html { redirect_to admin_pricing_group_path(@pricing_group),
          notice: t('.notice', pricing_group: @pricing_group) }
        format.json { render :show, status: :ok, location: admin_pricing_group_path(@pricing_group) }
      else
        format.html { render :edit }
        format.json { render json: @pricing_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/pricing_groups/1
  # DELETE /admin/pricing_groups/1.json
  def destroy
    @pricing_group.destroy
    respond_to do |format|
      format.html { redirect_to admin_pricing_groups_path,
        notice: t('.notice', pricing_group: @pricing_group) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pricing_group
      @pricing_group = current_store.pricing_groups.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pricing_group_params
      params.require(:pricing_group).permit(
        :name, :markup_percent
      )
    end
end
