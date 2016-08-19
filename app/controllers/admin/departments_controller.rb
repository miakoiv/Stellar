#encoding: utf-8

class Admin::DepartmentsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_department, only: [:show, :edit, :update, :destroy, :reorder_products]

  authority_actions reorder: 'update'
  authorize_actions_for Department

  layout 'admin'

  # GET /admin/departments
  # GET /admin/departments.json
  def index
    @departments = current_portal.departments
  end

  # GET /admin/departments/1
  # GET /admin/departments/1.json
  def show
  end

  # GET /admin/departments/new
  def new
    @department = current_portal.departments.build
  end

  # GET /admin/departments/1/edit
  def edit
  end

  # POST /admin/departments
  # POST /admin/departments.json
  def create
    @department = current_portal.departments.build(department_params)

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
      @department = current_portal.departments.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(
        :name, category_ids: []
      )
    end
end
