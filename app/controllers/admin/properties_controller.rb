#encoding: utf-8

class Admin::PropertiesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  authority_actions reorder: 'update'

  layout 'admin'

  authorize_actions_for Property
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # GET /admin/properties
  # GET /admin/properties.json
  def index
    @properties = current_store.properties.sorted
  end

  # GET /admin/properties/1
  # GET /admin/properties/1.json
  def show
    respond_to do |format|
      format.json { render json: @property.product_properties.to_json, status: 200 }
      format.html
    end
  end

  # GET /admin/properties/new
  def new
    @property = current_store.properties.build
  end

  # GET /admin/properties/1/edit
  def edit
  end

  # POST /admin/properties
  # POST /admin/properties.json
  def create
    @property = current_store.properties.build(property_params)

    respond_to do |format|
      if @property.save
        format.html { redirect_to edit_admin_property_path(@property),
          notice: t('.notice', property: @property) }
        format.json { render :show, status: :created, location: admin_property_path(@property) }
      else
        format.html { render :new }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/properties/1
  # PATCH/PUT /admin/properties/1.json
  def update
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to admin_property_path(@property),
          notice: t('.notice', property: @property) }
        format.json { render :show, status: :ok, location: admin_property_path(@property) }
      else
        format.html { render :edit }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/properties/1
  # DELETE /admin/properties/1.json
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_to admin_properties_path,
        notice: t('.notice', property: @property) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property
      @property = Property.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def property_params
      params.require(:property).permit(
        :value_type, :measurement_unit_id, :unit_pricing, :searchable, :name
      )
    end
end
