#encoding: utf-8

class Admin::IframesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  authority_actions reorder: 'update'

  authorize_actions_for Iframe
  before_action :set_iframe, only: [:update, :destroy]

  # No layout, this controller never renders HTML.

  # POST /admin/products/1/iframes
  def create
    @product = Product.friendly.find(params[:product_id])
    @iframe = @product.iframes.build(iframe_params)

    respond_to do |format|
      if @iframe.save
        format.js
      else
        format.json { render json: @iframe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/iframes/1
  def update
    respond_to do |format|
      if @iframe.update(iframe_params)
        format.js
      else
        format.json { render json: @iframe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/iframes/1
  def destroy
    respond_to do |format|
      if @iframe.destroy
        format.js
      end
    end
  end

  private
    def set_iframe
      @iframe = Iframe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def iframe_params
      params.require(:iframe).permit(
        :html
      )
    end
end
