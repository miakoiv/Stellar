#encoding: utf-8

class Admin::CustomAttributesController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  authorize_actions_for CustomAttribute
  before_action :set_custom_attribute, only: [:show, :edit, :update, :destroy]

  # GET /admin/custom_attributes
  # GET /admin/custom_attributes.json
  def index
    @custom_attributes = current_store.custom_attributes
  end

  # GET /admin/custom_attributes/1
  # GET /admin/custom_attributes/1.json
  def show
  end

  # GET /admin/custom_attributes/new
  def new
    @custom_attribute = current_store.custom_attributes.build
  end

  # GET /admin/custom_attributes/1/edit
  def edit
  end

  # POST /admin/custom_attributes
  # POST /admin/custom_attributes.json
  def create
    @custom_attribute = current_store.custom_attributes.build(custom_attribute_params)

    respond_to do |format|
      if @custom_attribute.save
        format.html { redirect_to edit_admin_custom_attribute_path(@custom_attribute),
          notice: t('.notice', custom_attribute: @custom_attribute) }
        format.json { render :show, status: :created, location: admin_custom_attribute_path(@custom_attribute) }
      else
        format.html { render :new }
        format.json { render json: @custom_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/custom_attributes/1
  # PATCH/PUT /admin/custom_attributes/1.json
  def update
    respond_to do |format|
      if @custom_attribute.update(custom_attribute_params)
        format.html { redirect_to admin_custom_attribute_path(@custom_attribute),
          notice: t('.notice', custom_attribute: @custom_attribute) }
        format.json { render :show, status: :ok, location: admin_custom_attribute_path(@custom_attribute) }
      else
        format.html { render :edit }
        format.json { render json: @custom_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/custom_attributes/1
  # DELETE /admin/custom_attributes/1.json
  def destroy
    @custom_attribute.destroy
    respond_to do |format|
      format.html { redirect_to admin_custom_attributes_path,
        notice: t('.notice', custom_attribute: @custom_attribute) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_attribute
      @custom_attribute = CustomAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_attribute_params
      params.require(:custom_attribute).permit(
        :measurement_unit_id, :unit_pricing, :name
      )
    end
end
