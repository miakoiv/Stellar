#encoding: utf-8

class Admin::AssetEntriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_customer_asset, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/customer_assets/1/asset_entries
  def create
    authorize_action_for AssetEntry, at: current_store
    @asset_entry = @customer_asset.asset_entries.build(asset_entry_params)

    respond_to do |format|
      if @asset_entry.save
        format.js { render 'create' }
      else
        format.json { render json: @asset_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_customer_asset
      @customer_asset = current_store.customer_assets.find(params[:customer_asset_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_entry_params
      params.require(:asset_entry).permit(
        :recorded_at, :amount, :value, :note
      )
    end
end
