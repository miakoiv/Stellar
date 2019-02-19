class Pos::ProductsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_product,  only: [:show]

  layout 'point_of_sale'

  # GET /pos/products/1
  # This method supplies product data JSON for UI widgets.
  def show
  end

  # GET /pos/products/query.json?q=keyword
  # This method serves selectize widgets populated via Ajax.
  def query
    @search = ProductSearch.new(query_params)
    @products = @search.results
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = current_store.products.friendly.find(params[:id])
    end

    def query_params
      params.permit(
        :q, {purposes: []}, {inventories: []}, {exclusions: []},
        :having_variants
      ).merge(search_constrains).merge(live: true)
    end

    # Impose search constrains from current store and group.
    def search_constrains
      {store: current_store}.tap do |c|
        c.merge!(vendor_id: current_group) if third_party?
        c.merge!(permitted_categories: current_group.available_categories) if current_group.limited_categories?
      end
    end
end
