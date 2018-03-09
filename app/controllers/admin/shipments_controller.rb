#encoding: utf-8

class Admin::ShipmentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, only: [:create]
  before_action :set_shipment, except: [:create]

  authority_actions refresh: 'update', complete: 'update'

  # No layout, this controller never renders HTML.

  # POST /admin/orders/1/shipments
  def create
    authorize_action_for Shipment, for: @order, at: current_store
    @shipment = @order.shipments.build(shipment_params)

    respond_to do |format|
      if @shipment.save
        @shipment.load!
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/shipments/1/refresh
  def refresh
    authorize_action_for @shipment, at: current_store
    @shipment.reload!

    respond_to :js
  end

  # PATCH/PUT /admin/shipments/1/complete
  def complete
    authorize_action_for @shipment, at: current_store

    respond_to do |format|
      if @shipment.complete!
        format.js { render :complete }
      else
        format.js { render :error }
      end
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
        :shipping_method_id
      )
    end
end
