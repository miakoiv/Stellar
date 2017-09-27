#encoding: utf-8

class Admin::PropertiesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  authority_actions reorder: 'update'

  layout 'admin'

  # GET /admin/properties
  # GET /admin/properties.json
  def index
    authorize_action_for Property, at: current_store
    @properties = current_store.properties
  end

  # GET /admin/properties/1
  # GET /admin/properties/1.json
  def show
    authorize_action_for @property, at: current_store

    respond_to do |format|
      format.json { render json: @property.product_properties, status: 200 }
      format.html
    end
  end

  # GET /admin/properties/new
  def new
    authorize_action_for Property, at: current_store
    @property = current_store.properties.build
  end

  # GET /admin/properties/1/edit
  def edit
    authorize_action_for @property, at: current_store
  end

  # POST /admin/properties
  # POST /admin/properties.json
  def create
    authorize_action_for Property, at: current_store
    @property = current_store.properties.build(property_params.merge(priority: current_store.properties.count))

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
    authorize_action_for @property, at: current_store

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
    authorize_action_for @property, at: current_store
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
      @property = current_store.properties.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def property_params
      params.require(:property).permit(
        :value_type, :measurement_unit_id, :unit_pricing, :searchable, :name
      )
    end
end
