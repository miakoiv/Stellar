#encoding: utf-8

class Admin::PromotionsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_promotion,
    only: [:show, :edit, :update, :destroy, :add_products, :add_categories]

  authority_actions add_products: 'update', add_categories: 'update'

  layout 'admin'

  # GET /admin/promotions
  # GET /admin/promotions.json
  def index
    authorize_action_for Promotion, at: current_store
    @promotions = current_store.promotions
  end

  # GET /admin/promotions/1
  # GET /admin/promotions/1.json
  def show
    authorize_action_for @promotion, at: current_store
  end

  # GET /admin/promotions/new
  def new
    authorize_action_for Promotion, at: current_store
    @promotion = current_store.promotions.build
  end

  # GET /admin/promotions/1/edit
  def edit
    authorize_action_for @promotion, at: current_store
  end

  # POST /admin/promotions
  # POST /admin/promotions.json
  def create
    authorize_action_for Promotion, at: current_store
    @promotion = current_store.promotions.build(promotion_params)
    @promotion.build_promotion_handler(type: @promotion.promotion_handler_type)

    respond_to do |format|
      if @promotion.save
        track @promotion
        format.html { redirect_to edit_admin_promotion_path(@promotion),
          notice: t('.notice', promotion: @promotion) }
        format.json { render :show, status: :created, location: admin_promotion_path(@promotion) }
      else
        format.html { render :new }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/promotions/1
  # PATCH/PUT /admin/promotions/1.json
  def update
    authorize_action_for @promotion, at: current_store

    respond_to do |format|
      if @promotion.update(promotion_params)
        track @promotion
        format.html { redirect_to admin_promotion_path(@promotion),
          notice: t('.notice', promotion: @promotion) }
        format.json { render :show, status: :ok, location: admin_promotion_path(@promotion) }
      else
        format.html { render :edit }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/promotions/1
  # DELETE /admin/promotions/1.json
  def destroy
    authorize_action_for @promotion, at: current_store
    track @promotion
    @promotion.destroy

    respond_to do |format|
      format.html { redirect_to admin_promotions_path,
        notice: t('.notice', promotion: @promotion) }
      format.json { head :no_content }
    end
  end

  # POST /admin/promotions/1/add_products
  def add_products
    authorize_action_for @promotion, at: current_store
    product_ids = params[:promotion][:product_ids_string]
      .split(',').map(&:to_i)
    track @promotion, nil, {
      action: 'update',
      differences: {added_products: product_ids}
    }
    ActiveRecord::Base.transaction do
      product_ids.each do |product_id|
        @promotion.add(Product.find(product_id))
      end
    end
    respond_to :js
  end

  # POST /admin/promotions/1/add_categories
  def add_categories
    authorize_action_for @promotion, at: current_store
    category_ids = params[:promotion][:category_ids_string]
      .split(',').map(&:to_i)
    track @promotion, nil, {
      action: 'update',
      differences: {added_categories: category_ids}
    }
    ActiveRecord::Base.transaction do
      category_ids.each do |category_id|
        category = Category.find(category_id)
        category.products.live.each do |product|
          @promotion.add(product)
        end
      end
    end
    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = current_store.promotions.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(
        :name, :group_id, :promotion_handler_type,
        :first_date, :last_date, :activation_code,
        promotion_handler_attributes: [
          :id, :description, :default_price,
          :order_total, :required_items, :items_total,
          :discount_percent
        ]
      )
    end
end
