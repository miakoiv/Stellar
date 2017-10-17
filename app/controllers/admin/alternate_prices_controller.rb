#encoding: utf-8

class Admin::AlternatePricesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/products/1/alternate_prices
  def create
    @alternate_price = @product.alternate_prices.find_or_initialize_by(
      group_id: params[:alternate_price][:group_id]
    )
    respond_to do |format|
      if @alternate_price.update(alternate_price_params)
        format.js { render 'create' }
      else
        format.json { render json: @alternate_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/alternate_prices/1
  def destroy
    @alternate_price = AlternatePrice.find(params[:id])

    respond_to do |format|
      if @alternate_price.destroy
        format.js
      end
    end
  end

  private
    def set_product
      @product = current_store.products.friendly.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alternate_price_params
      params.require(:alternate_price).permit(
        :group_id, :price
      )
    end
end
