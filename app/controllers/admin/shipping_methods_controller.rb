#encoding: utf-8

class Admin::ShippingMethodsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_shipping_method, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/shipping_methods
  # GET /admin/shipping_methods.json
  def index
    authorize_action_for ShippingMethod, at: current_store
    @shipping_methods = current_store.shipping_methods
  end

  # GET /admin/shipping_methods/1
  # GET /admin/shipping_methods/1.json
  def show
    authorize_action_for @shipping_method, at: current_store
  end

  # GET /admin/shipping_methods/new
  def new
    authorize_action_for ShippingMethod, at: current_store
    @shipping_method = current_store.shipping_methods.build
  end

  # GET /admin/shipping_methods/1/edit
  def edit
    authorize_action_for @shipping_method, at: current_store
  end

  # POST /admin/shipping_methods
  # POST /admin/shipping_methods.json
  def create
    authorize_action_for ShippingMethod, at: current_store
    @shipping_method = current_store.shipping_methods.build(shipping_method_params)

    respond_to do |format|
      if @shipping_method.save
        format.html { redirect_to admin_shipping_method_path(@shipping_method),
          notice: t('.notice', shipping_method: @shipping_method) }
        format.json { render :show, status: :created, location: admin_shipping_method_path(@shipping_method) }
      else
        format.html { render :new }
        format.json { render json: @shipping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/shipping_methods/1
  # PATCH/PUT /admin/shipping_methods/1.json
  def update
    authorize_action_for @shipping_method, at: current_store

    respond_to do |format|
      if @shipping_method.update(shipping_method_params)
        format.html { redirect_to admin_shipping_method_path(@shipping_method),
          notice: t('.notice', shipping_method: @shipping_method) }
        format.json { render :show, status: :ok, location: admin_shipping_method_path(@shipping_method) }
      else
        format.html { render :edit }
        format.json { render json: @shipping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/shipping_methods/1
  # DELETE /admin/shipping_methods/1.json
  def destroy
    authorize_action_for @shipping_method, at: current_store
    @shipping_method.destroy

    respond_to do |format|
      format.html { redirect_to admin_shipping_methods_path,
        notice: t('.notice', shipping_method: @shipping_method) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipping_method
      @shipping_method = current_store.shipping_methods.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipping_method_params
      params.require(:shipping_method).permit(
        :name, :code, :shipping_gateway, :has_pickup_points, :home_delivery,
        :delivery_time, :enabled_at, :disabled_at,
        :description, :shipping_cost_product_id, :free_shipping_from,
        :detail_page_id
      )
    end
end
