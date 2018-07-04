#encoding: utf-8

class Admin::ShipmentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, only: [:create]
  before_action :set_shipment, except: [:create]

  authority_actions refresh: 'update', complete: 'update', label: 'read'

  # No layout, this controller never renders HTML.

  # GET /admin/shipments/1/edit
  def edit
    authorize_action_for @shipment, at: current_store

    respond_to :js
  end

  # POST /admin/orders/1/shipments
  def create
    authorize_action_for Shipment, for: @order, at: current_store
    @shipment = @order.shipments.build(shipment_params)

    respond_to do |format|
      if @shipment.save
        track @shipment, @order
        @shipment.load!
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/shipments/1
  def update
    authorize_action_for @shipment, at: current_store

    respond_to do |format|
      if @shipment.update(shipment_params)
        track @shipment, @shipment.order
        format.js { render :update }
      else
        format.js { render :rollback }
      end
    end
  end

  # DELETE /admin/shipments/1
  def destroy
    authorize_action_for @shipment, at: current_store
    @order = @shipment.order
    track @shipment, @order
    @shipment.cancel!

    respond_to :js
  end

  # PATCH/PUT /admin/shipments/1/refresh
  def refresh
    authorize_action_for @shipment, at: current_store
    @order = @shipment.order
    track @shipment, @order, {
      action: 'update',
      differences: @shipment.transfer.transfer_items
    }
    @shipment.reload!

    respond_to :js
  end

  # PATCH/PUT /admin/shipments/1/complete
  def complete
    authorize_action_for @shipment, at: current_store
    @order = @shipment.order
    shipping_gateway = @shipment.shipping_gateway.new(
      order: @order, shipment: @shipment, user: current_user
    )
    status, number, tracking_code = shipping_gateway.send_shipment

    respond_to do |format|
      if status && @shipment.update(
        number: number,
        tracking_code: tracking_code
      ) && @shipment.complete!
        track @shipment, @order, {action: 'conclude'}
        format.js { render :complete }
      else
        format.js { render :error }
      end
    end
  end

  # GET /admin/shipments/1/label
  def label
    authorize_action_for @shipment, at: current_store
    @order = @shipment.order
    shipping_gateway = @shipment.shipping_gateway.new(
      order: @order, shipment: @shipment, user: current_user
    )
    status, file = shipping_gateway.fetch_label

    respond_to do |format|
      format.pdf { send_data(file, filename: "#{@shipment.number}.pdf", type: 'application/pdf') }
    end
  end

  private
    def set_order
      @order = current_store.orders.find(params[:order_id])
    end

    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_params
      params.require(:shipment).permit(
        :shipping_method_id, :package_type, :mass,
        :dimension_u, :dimension_v, :dimension_w
      )
    end
end
