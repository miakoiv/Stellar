#encoding: utf-8

class Admin::GroupsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  authority_actions reorder: 'update'

  layout 'admin'

  # GET /admin/groups
  # GET /admin/groups.json
  def index
    authorize_action_for Group, at: current_store
    @groups = current_store.groups
  end

  # GET /admin/groups/1
  # GET /admin/groups/1.json
  def show
    authorize_action_for @group, at: current_store
  end

  # GET /admin/groups/new
  def new
    authorize_action_for Group, at: current_store
    @group = current_store.groups.build
  end

  # GET /admin/groups/1/edit
  def edit
    authorize_action_for @group, at: current_store
  end

  # POST /admin/departments
  # POST /admin/departments.json
  def create
    authorize_action_for Group, at: current_store
    @group = current_store.groups.build(group_params.merge(priority: current_store.groups.count))

    respond_to do |format|
      if @group.save
        format.html { redirect_to edit_admin_group_path(@group),
          notice: t('.notice', group: @group) }
        format.json { render :show, status: :created, location: admin_group_path(@group) }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/groups/1
  # PATCH/PUT /admin/groups/1.json
  def update
    authorize_action_for @group, at: current_store

    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to admin_group_path(@group),
          notice: t('.notice', group: @group) }
        format.json { render :show, status: :ok, location: admin_group_path(@group) }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/groups/1
  # DELETE /admin/groups/1.json
  def destroy
    authorize_action_for @group, at: current_store
    @group.destroy

    respond_to do |format|
      format.html { redirect_to admin_groups_path,
        notice: t('.notice', group: @group) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = current_store.groups.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(
        :name, :appearance,
        :price_base, :price_markup_percent, :price_tax_included
      )
    end
end
