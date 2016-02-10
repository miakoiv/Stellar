#encoding: utf-8

class Admin::PromotionsController < ApplicationController

  before_action :authenticate_user!
  authority_actions add_products: 'update'
  authority_actions add_categories: 'update'

  layout 'admin'

  authorize_actions_for Promotion
  before_action :set_promotion,
    only: [:show, :edit, :update, :destroy, :add_products, :add_categories]

  # GET /admin/promotions
  # GET /admin/promotions.json
  def index
    @promotions = current_store.promotions
  end

  # GET /admin/promotions/1
  # GET /admin/promotions/1.json
  def show
  end

  # GET /admin/promotions/new
  def new
    @promotion = current_store.promotions.build
  end

  # GET /admin/promotions/1/edit
  def edit
  end

  # POST /admin/promotions
  # POST /admin/promotions.json
  def create
    @promotion = current_store.promotions.build(promotion_params)
    @promotion.build_promotion_handler(type: @promotion.promotion_handler_type)

    respond_to do |format|
      if @promotion.save
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
    respond_to do |format|
      if @promotion.update(promotion_params)
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
    @promotion.destroy
    respond_to do |format|
      format.html { redirect_to admin_promotions_path,
        notice: t('.notice', promotion: @promotion) }
      format.json { head :no_content }
    end
  end

  # POST /admin/promotions/1/add_products
  def add_products
    product_ids = params[:promotion][:product_ids_string]
      .split(',').map(&:to_i)

    product_ids.each do |product_id|
      @promotion.promoted_items.find_or_create_by(
        product: Product.find(product_id)
      )
    end

    respond_to do |format|
      format.js
    end
  end

  # POST /admin/promotions/1/add_categories
  def add_categories
    category_ids = params[:promotion][:category_ids_string]
      .split(',').map(&:to_i)

    category_ids.each do |category_id|
      category = Category.find(category_id)
      category.products.live.each do |product|
        @promotion.promoted_items.find_or_create_by(
          product: product
        )
      end
    end

    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(
        :name, :promotion_handler_type, :first_date, :last_date,
        promotion_handler_attributes: [
          :id, :description,
          :order_total_cents, :required_items, :discount_percent
        ]
      )
    end
end
