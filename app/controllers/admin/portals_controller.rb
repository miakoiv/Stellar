#encoding: utf-8

class Admin::PortalsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_portal, only: [:show, :edit, :update, :destroy]

  authorize_actions_for Portal

  layout 'admin'

  # GET /admin/portals
  def index
    @portals = Portal.all
  end

  # GET /admin/portals/1
  def show
  end

  # GET /admin/portals/new
  def new
    @portal = Portal.new
  end

  # GET /admin/portals/1/edit
  def edit
  end

  # POST /admin/portals
  # POST /admin/portals.json
  def create
    @portal = Portal.new(portal_params)

    respond_to do |format|
      if @portal.save
        format.html { redirect_to edit_admin_portal_path(@portal),
          notice: t('.notice', portal: @portal) }
        format.json { render :show, status: :created, location: admin_portal_path(@portal) }
      else
        format.html { render :new }
        format.json { render json: @portal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/portals/1
  # PATCH/PUT /admin/portals/1.json
  def update
    respond_to do |format|
      if @portal.update(portal_params)
        format.html { redirect_to admin_portal_path(@portal),
          notice: t('.notice', portal: @portal) }
        format.json { render :show, status: :ok, location: admin_portal_path(@portal) }
      else
        format.html { render :edit }
        format.json { render json: @portal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/portals/1
  # DELETE /admin/portals/1.json
  def destroy
    @portal.destroy
    respond_to do |format|
      format.html { redirect_to admin_portals_path,
        notice: t('.notice', portal: @portal) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portal
      @portal = Portal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def portal_params
      params.require(:portal).permit(
        :domain, :name, :theme, :locale, store_ids: []
      )
    end
end
