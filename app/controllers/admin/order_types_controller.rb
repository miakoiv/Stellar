#encoding: utf-8

class Admin::OrderTypesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order_type, only: [:show, :edit, :update, :destroy]

  authorize_actions_for OrderType, except: [:destroy]

  layout 'admin'

  # GET /admin/order_types
  # GET /admin/order_types.json
  def index
    @order_types = current_store.order_types
  end

  # GET /admin/order_types/1
  # GET /admin/order_types/1.json
  def show
  end

  # GET /admin/order_types/new
  def new
    @order_type = current_store.order_types.build
  end

  # GET /admin/order_types/1/edit
  def edit
  end

  # POST /admin/order_types
  # POST /admin/order_types.json
  def create
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
    authorize_action_for @order_type
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
        :name, :source_group, :destination_group,
        :has_shipping, :has_installation,
        :has_payment, :payment_gateway,
        :is_exported
      )
    end
end
