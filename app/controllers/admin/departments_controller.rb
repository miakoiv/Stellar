#encoding: utf-8

class Admin::DepartmentsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_department, only: [:show, :edit, :update, :destroy, :reorder_products]

  authority_actions reorder: 'update'

  layout 'admin'

  # GET /admin/departments
  # GET /admin/departments.json
  def index
    authorize_action_for Department, at: current_store
    @departments = current_store.departments
  end

  # GET /admin/departments/1
  # GET /admin/departments/1.json
  def show
    authorize_action_for @department, at: current_store
  end

  # GET /admin/departments/new
  def new
    authorize_action_for Department, at: current_store
    @department = current_store.departments.build
  end

  # GET /admin/departments/1/edit
  def edit
    authorize_action_for @department, at: current_store
  end

  # POST /admin/departments
  # POST /admin/departments.json
  def create
    authorize_action_for Department, at: current_store
    @department = current_store.departments.build(department_params.merge(priority: current_store.departments.count))

    respond_to do |format|
      if @department.save
        format.html { redirect_to edit_admin_department_path(@department),
          notice: t('.notice', department: @department) }
        format.json { render :show, status: :created, location: admin_department_path(@department) }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/departments/1
  # PATCH/PUT /admin/departments/1.json
  def update
    authorize_action_for @department, at: current_store

    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to admin_department_path(@department),
          notice: t('.notice', department: @department) }
        format.json { render :show, status: :ok, location: admin_department_path(@department) }
      else
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/departments/1
  # DELETE /admin/departments/1.json
  def destroy
    authorize_action_for @department, at: current_store
    @department.destroy

    respond_to do |format|
      format.html { redirect_to admin_departments_path,
        notice: t('.notice', department: @department) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = current_store.departments.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(
        :name, category_ids: []
      )
    end
end
