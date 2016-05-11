#encoding: utf-8

class Admin::RequisiteEntriesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  # No layout, this controller never renders HTML.

  # DELETE /admin/requisite_entries/1
  def destroy
    @requisite_entry = RequisiteEntry.find(params[:id])

    respond_to do |format|
      if @requisite_entry.destroy
        format.js
      end
    end
  end

  private
    def set_product
      @product = current_store.products.friendly.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requisite_entry_params
      params.require(:requisite_entry).permit(
        :requisite_id
      )
    end
end
