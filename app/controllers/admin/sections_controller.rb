#encoding: utf-8

class Admin::SectionsController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_section, only: [:update, :destroy]

  authority_actions reorder: 'update'
  authorize_actions_for Section

  # No layout, this controller never renders HTML.

  # GET /admin/pages/1/sections/create.js
  def create
    @page = current_store.pages.friendly.find(params[:page_id])
    @section = @page.sections.build(section_params.merge(priority: @page.sections.count))

    respond_to do |format|
      if @section.save
        create_segments!
        format.js
      else
        format.js { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/sections/1.js
  def update
    respond_to do |format|
      if @section.update(section_params)
        format.js
      else
        format.js { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/sections/1.js
  def destroy
    respond_to do |format|
      if @section.destroy
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Create segments according to given layout preset.
    def create_segments!
      preset = params[:preset]
      template = @section.block? ? 'picture' : 'column'
      Section::SEGMENTS[preset].each do |measure|
        @section.segments.create(template: template, measure: measure)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(
        :width, :layout, :height, :alignment, :background_color
      )
    end
end
