#encoding: utf-8

class Admin::SegmentsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_segment, only: [:show, :edit, :update, :destroy]

  authority_actions reorder: 'update'

  # No layout, this controller never renders HTML.

  # GET /admin/segments/1.js
  def show
    authorize_action_for @segment, at: current_store

    respond_to :js
  end

  # GET /admin/segments/1/edit.js
  def edit
    authorize_action_for @segment, at: current_store

    respond_to :js
  end

  # POST /admin/columns/1/segments.js
  def create
    @column = Column.find(params[:column_id])
    authorize_action_for @column, at: current_store
    @segment = @column.segments.build(segment_params.merge(template: 'text', priority: @column.segments.count))

    respond_to do |format|
      if @segment.save
        format.js { render 'create' }
      else
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/segments/1.js
  def update
    authorize_action_for @segment, at: current_store

    respond_to do |format|
      if @segment.update(segment_params)
        format.js
      else
        format.js { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/columns/1/segments/reorder
  def reorder
    @column = Column.find(params[:column_id])
    authorize_action_for @column, at: current_store

    ActiveRecord::Base.transaction do
      reordered_items.each_with_index do |item, index|
        item.update(column: @column, priority: index)
      end
    end
    render nothing: true
  end

  # DELETE /admin/segments/1.js
  def destroy
    authorize_action_for @segment, at: current_store

    respond_to do |format|
      if @segment.destroy
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_segment
      @segment = Segment.joins(:column).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def segment_params
      params.fetch(:segment) {{}}.permit(
        :resource_id, :resource_type,
        :template, :alignment, :shape, :inset,
        :body, :header, :subhead, :url,
        :min_height, :grid_columns, :masonry,
        :max_items, :product_scope, :show_more,
        :map_location, :map_zoom,
        :inverse
      )
    end
end
