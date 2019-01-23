#encoding: utf-8

class Admin::RequisiteEntriesController < AdminController

  include Reorderer

  # DELETE /admin/requisite_entries/1
  def destroy
    @requisite_entry = RequisiteEntry.find(params[:id])
    track @requisite_entry, @requisite_entry.product

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
