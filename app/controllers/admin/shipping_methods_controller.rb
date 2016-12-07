#encoding: utf-8

class Admin::ShippingMethodsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_shipping_method, only: [:show, :edit, :update, :destroy]

  authorize_actions_for ShippingMethod

  layout 'admin'

  # GET /admin/shipping_methods
  # GET /admin/shipping_methods.json
  def index
    @shipping_methods = current_store.shipping_methods
  end

  # GET /admin/shipping_methods/1
  # GET /admin/shipping_methods/1.json
  def show
  end

  # GET /admin/shipping_methods/new
  def new
    @shipping_method = current_store.shipping_methods.build
  end

  # GET /admin/shipping_methods/1/edit
  def edit
  end

  # POST /admin/shipping_methods
  # POST /admin/shipping_methods.json
  def create
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
        :name, :shipping_gateway, :delivery_time, :enabled_at, :disabled_at,
        :description, :shipping_cost_product_id, :detail_page_id
      )
    end
end
