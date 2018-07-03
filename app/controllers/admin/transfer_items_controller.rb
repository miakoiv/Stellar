#encoding: utf-8

class Admin::TransferItemsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_transfer, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/transfers/1/transfer_items
  def create
    @transfer_item = @transfer.transfer_items.build(transfer_item_params)

    respond_to do |format|
      if @transfer_item.save
        track @transfer_item, @transfer
        format.js { render :create }
      else
        format.js { render :error }
      end
    end
  end

  # PATCH/PUT /admin/transfer_items/1
  def update
    @transfer_item = TransferItem.find(params[:id])
    @transfer = @transfer_item.transfer

    respond_to do |format|
      if @transfer_item.update(transfer_item_params)
        track @transfer_item, @transfer
        format.js { render :update }
      else
        format.js { render :error }
      end
    end
  end

  # DELETE /admin/transfer_items/1
  def destroy
    @transfer_item = TransferItem.find(params[:id])
    @transfer = @transfer_item.transfer
    track @transfer_item, @transfer

    @transfer_item.destroy
  end

  private
    def set_transfer
      @transfer = current_store.transfers.find(params[:transfer_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_item_params
      params.require(:transfer_item).permit(
        :product_id, :lot_code, :expires_at, :amount,
        :customer_code, :serial
      )
    end
end
