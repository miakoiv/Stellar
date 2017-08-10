#encoding: utf-8

class Admin::SegmentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_segment, only: [:show, :edit, :update]

  authorize_actions_for Segment

  # No layout, this controller never renders HTML.

  # GET /admin/segments/1.js
  def show
    respond_to :js
  end

  # GET /admin/segments/1/edit.js
  def edit
    respond_to :js
  end

  # PATCH/PUT /admin/segments/1.js
  def update
    respond_to do |format|
      if @segment.update(segment_params)
        format.js
      else
        format.js { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_segment
      @segment = Segment.joins(:section).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def segment_params
      params.fetch(:segment) {{}}.permit(
        :resource_id, :resource_type, :template, :measure,
        :body, :grid_columns, :headline,
        :map_location, :map_zoom
      )
    end
end
