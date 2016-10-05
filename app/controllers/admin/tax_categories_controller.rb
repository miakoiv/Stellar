#encoding: utf-8

class Admin::TaxCategoriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_tax_category, only: [:show, :edit, :update, :destroy]

  authorize_actions_for TaxCategory

  layout 'admin'

  # GET /admin/tax_categories
  # GET /admin/tax_categories.json
  def index
    @tax_categories = current_store.tax_categories
  end

  # GET /admin/tax_categories/1
  # GET /admin/tax_categories/1.json
  def show
  end

  # GET /admin/tax_categories/new
  def new
    @tax_category = current_store.tax_categories.build
  end

  # GET /admin/tax_categories/1/edit
  def edit
  end

  # POST /admin/tax_categories
  # POST /admin/tax_categories.json
  def create
    @tax_category = current_store.tax_categories.build(tax_category_params)

    respond_to do |format|
      if @tax_category.save
        format.html { redirect_to admin_tax_category_path(@tax_category),
          notice: t('.notice', tax_category: @tax_category) }
        format.json { render :show, status: :created, location: admin_tax_category_path(@tax_category) }
      else
        format.html { render :new }
        format.json { render json: @tax_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/tax_categories/1
  # PATCH/PUT /admin/tax_categories/1.json
  def update
    respond_to do |format|
      if @tax_category.update(tax_category_params)
        format.html { redirect_to admin_tax_category_path(@tax_category),
          notice: t('.notice', tax_category: @tax_category) }
        format.json { render :show, status: :ok, location: admin_tax_category_path(@tax_category) }
      else
        format.html { render :edit }
        format.json { render json: @tax_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/tax_categories/1
  # DELETE /admin/tax_categories/1.json
  def destroy
    @tax_category.destroy
    respond_to do |format|
      format.html { redirect_to admin_tax_categories_path,
        notice: t('.notice', tax_category: @tax_category) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tax_category
      @tax_category = current_store.tax_categories.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tax_category_params
      params.require(:tax_category).permit(
        :name, :rate, :included_in_retail
      )
    end
end
