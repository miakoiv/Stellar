#encoding: utf-8

class Admin::OrderTypesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order_type, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/order_types
  # GET /admin/order_types.json
  def index
    authorize_action_for OrderType, at: current_store
    @order_types = current_store.order_types
  end

  # GET /admin/order_types/1
  # GET /admin/order_types/1.json
  def show
    authorize_action_for @order_type, at: current_store
  end

  # GET /admin/order_types/new
  def new
    authorize_action_for OrderType, at: current_store
    @order_type = current_store.order_types.build(
      has_shipping: true, has_payment: true
    )
  end

  # GET /admin/order_types/1/edit
  def edit
    authorize_action_for @order_type, at: current_store
  end

  # POST /admin/order_types
  # POST /admin/order_types.json
  def create
    authorize_action_for OrderType, at: current_store
    @order_type = current_store.order_types.build(order_type_params)

    respond_to do |format|
      if @order_type.save
        format.html { redirect_to edit_admin_order_type_path(@order_type),
          notice: t('.notice', order_type: @order_type) }
        format.json { render :show, status: :created, location: admin_order_type_path(@order_type) }
      else
        format.html { render :new }
        format.json { render json: @order_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/order_types/1
  # PATCH/PUT /admin/order_types/1.json
  def update
    authorize_action_for @order_type, at: current_store

    respond_to do |format|
      if @order_type.update(order_type_params)
        format.html { redirect_to admin_order_type_path(@order_type),
          notice: t('.notice', order_type: @order_type) }
        format.json { render :show, status: :ok, location: admin_order_type_path(@order_type) }
      else
        format.html { render :edit }
        format.json { render json: @order_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/order_types/1
  # DELETE /admin/order_types/1.json
  def destroy
    authorize_action_for @order_type, at: current_store
    @order_type.destroy

    respond_to do |format|
      format.html { redirect_to admin_order_types_path,
        notice: t('.notice', order_type: @order_type) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_type
      @order_type = current_store.order_types.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_type_params
      params.require(:order_type).permit(
        :source_id, :destination_id, :name,
        :has_shipping, :has_installation,
        :has_payment, :payment_gateway,
        :is_exported
      )
    end
end
