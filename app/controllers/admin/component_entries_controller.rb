#encoding: utf-8

class Admin::ComponentEntriesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/products/1/component_entries
  def create
    @component_entry = @product.component_entries.find_or_initialize_by(
      component_id: params[:component_entry][:component_id]
    )
    @component_entry.priority = @product.component_entries.count if @component_entry.new_record?

    respond_to do |format|
      if @component_entry.update(component_entry_params)
        format.js { render 'create' }
      else
        format.json { render json: @component_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/component_entries/1
  def destroy
    @component_entry = ComponentEntry.find(params[:id])

    respond_to do |format|
      if @component_entry.destroy
        format.js
      end
    end
  end

  private
    def set_product
      @product = current_store.products.friendly.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def component_entry_params
      params.require(:component_entry).permit(
        :component_id, :quantity
      )
    end
end
