#encoding: utf-8

class Admin::SegmentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_segment, only: [:show, :edit, :update, :switch]

  authority_actions switch: 'update'

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

  # POST /admin/segments/1/switch.js
  def switch
    authorize_action_for @segment, at: current_store
    @other = Segment.joins(:section).find(params[:other_id])
    @segment.switch(@other)
    @sections = [@segment.section, @other.section].uniq

    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_segment
      @segment = Segment.joins(:section).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def segment_params
      params.fetch(:segment) {{}}.permit(
        :resource_id, :resource_type, :template, :alignment, :inset,
        :body, :header, :subhead, :url,
        :min_height, :grid_columns, :masonry,
        :max_items, :product_scope, :show_more,
        :map_location, :map_zoom,
        :inverse
      )
    end
end
