#encoding: utf-8

class Admin::PromotedItemsController < AdminController

  before_action :set_promotion, only: [:create]

  # POST /admin/promotions/1/promoted_items
  def create
    @promoted_item = @promotion.promoted_items.build(promoted_item_params)

    respond_to do |format|
      if @promoted_item.save
        track @promoted_item, @promotion
        format.js
      end
    end
  end

  # PATCH/PUT /admin/promoted_items/1
  def update
    @promoted_item = PromotedItem.find(params[:id])
    @promoted_item.assign_attributes(promoted_item_params)

    respond_to do |format|
      if @promoted_item.valid?
        @promoted_item.save
        track @promoted_item, @promoted_item.promotion
        @promoted_item.reload
        format.js { render :update }
      else
        format.js { render :rollback }
      end
    end
  end

  # DELETE /admin/promoted_items/1
  def destroy
    @promoted_item = PromotedItem.find(params[:id])
    @promotion = @promoted_item.promotion
    track @promoted_item, @promotion

    respond_to do |format|
      if @promoted_item.destroy
        format.js
      end
    end
  end

  private
    def set_promotion
      @promotion = current_store.promotions.find(params[:promotion_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promoted_item_params
      params.require(:promoted_item).permit(
        :price, :discount_percent, :amount_available
      )
    end
end
