#encoding: utf-8

class Admin::RelationshipsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/products/1/relationships
  def create
    @relationship = @product.relationships.find_or_initialize_by(
      component_id: params[:relationship][:component_id]
    )
    respond_to do |format|
      if @relationship.update(relationship_params)
        format.js { render 'create' }
      else
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/relationships/1
  def destroy
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if @relationship.destroy
        format.js
      end
    end
  end

  private
    def set_product
      @product = current_store.products.friendly.find(params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationship_params
      params.require(:relationship).permit(
        :component_id, :quantity
      )
    end
end
