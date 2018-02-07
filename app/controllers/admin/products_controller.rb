#encoding: utf-8

class Admin::ProductsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_product,  only: [:show, :edit, :update, :destroy, :duplicate, :add_requisite_entries, :make_primary]

  authority_actions query: 'read', reorder: 'update', upload_file: 'update', add_requisite_entries: 'update', make_primary: 'update', duplicate: 'create'

  layout 'admin'

  # GET /admin/products
  # GET /admin/products.json
  def index
    authorize_action_for Product, at: current_store
    @query = saved_search_query('product', 'admin_product_search')
    @search = ProductSearch.new(search_params)
    @products = @search.results.master.alphabetical.page(params[:page])
  end

  # GET /admin/products/query.json?q=keyword
  # This method serves selectize widgets populated via Ajax.
  def query
    authorize_action_for Product, at: current_store
    @query = {'keyword' => params[:q], live: true}.merge(params)
    @search = ProductSearch.new(search_params)
    @products = @search.results
  end

  # GET /admin/products/1
  # GET /admin/products/1.json
  def show
    authorize_action_for @product, at: current_store
  end

  # GET /admin/products/new
  def new
    authorize_action_for Product, at: current_store
    master = current_store.products.find_by(slug: params[:master])
    @product = current_store.products.build(
      vendor: third_party? ? current_group : nil,
      available_at: Date.current,
      tax_category: current_store.tax_categories.first
    )
    @product.vary_from(master) if master.present?
  end

  # GET /admin/products/1/edit
  # GET /admin/products/1/edit.js
  def edit
    authorize_action_for @product, at: current_store

    respond_to :html, :js
  end

  # POST /admin/products
  # POST /admin/products.json
  def create
    authorize_action_for Product, at: current_store
    @product = current_store.products.build(product_params)
    @product.vendor = current_group if third_party?
    @product.priority = @product.master_product.variants_count if @product.variant?

    respond_to do |format|
      if @product.save
        format.html { redirect_to edit_admin_product_path(@product),
          notice: t('.notice', product: @product) }
        format.json { render :show, status: :created, location: admin_product_path(@product) }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1
  # PATCH/PUT /admin/products/1.js
  # PATCH/PUT /admin/products/1.json
  def update
    authorize_action_for @product, at: current_store

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to admin_product_path(@product),
          notice: t('.notice', product: @product) }
        format.js { flash.now[:notice] = t('.notice', product: @product) }
        format.json { render :show, status: :ok, location: admin_product_path(@product) }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/products/1/duplicate
  def duplicate
    authorize_action_for @product, at: current_store
    original = @product
    @product = original.duplicate!

    redirect_to edit_admin_product_path(@product),
      notice: t('.notice', product: original)
  end

  # POST /admin/products/1/add_requisite_entries
  def add_requisite_entries
    authorize_action_for @product, at: current_store

    requisite_ids = params[:product][:requisite_ids_string]
      .split(',').map(&:to_i)

    requisite_ids.each do |requisite_id|
      @product.requisite_entries.find_or_create_by(
        requisite: Product.find(requisite_id)
      ).update(priority: @product.requisite_entries.count)
    end

    respond_to :js
  end

  # PATCH/PUT /admin/products/1/make_primary.js
  def make_primary
    authorize_action_for @product, at: current_store

    @master = @product.master_product
    if @master.update primary_variant: @product
      @master.variants.each do |variant|
        variant.touch
      end
    end

    respond_to :js
  end

  # POST /admin/products/upload_file
  def upload_file
    uploader = Uploaders::Products.new(params.merge(store_id: current_store.id))
    updated = uploader.process

    respond_to do |format|
      format.json { render json: updated, status: 200 }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = current_store.products.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(
        :purpose, :master_product_id, {variant_ids: []},
        :vendor_id, :code, :customer_code,
        :title, :subtitle, :description, :overview, :memo,
        :mass, :dimension_u, :dimension_v, :dimension_w,
        :lead_time, :shipping_notes,
        :cost_price, :trade_price, :retail_price, :tax_category_id,
        :available_at, :deleted_at, {category_ids: []},
        {shipping_method_ids: []}
      )
    end

    # Restrict searching to products in current store.
    def search_params
      params = {store: current_store}
      params.merge!(vendor_id: current_group) if third_party?
      params.merge!(permitted_categories: current_group.available_categories) if current_group.limited_categories?
      @query.merge(params)
    end
end
