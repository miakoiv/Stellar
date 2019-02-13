class Admin::SectionsController < AdminController

  include Reorderer

  before_action :set_section, only: [:settings, :preload, :update, :modify, :destroy]

  authority_actions settings: 'update', reorder: 'update'

  # GET /admin/pages/1/sections/create.js
  def create
    authorize_action_for Section, at: current_store
    @page = current_store.pages.friendly.find(params[:page_id])
    @section = @page.sections.build(section_params.merge(priority: @page.sections.any? ? 1 + @page.sections.maximum(:priority) : 0))

    respond_to do |format|
      if @section.save
        create_columns!
        format.js
      else
        format.js { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/sections/1/settings.js
  def settings
    authorize_action_for @section, at: current_store

    respond_to :js
  end

  # GET /admin/sections/1/preload.js
  def preload
    respond_to :js
  end

  # PATCH/PUT /admin/sections/1.js
  def update
    authorize_action_for @section, at: current_store

    respond_to do |format|
      if @section.update(section_params)
        format.js { render :update }
      else
        format.js { render :rollback }
      end
    end
  end

  # PATCH/PUT /admin/sections/1/modify.js
  def modify
    @section.update(section_params)
    respond_to :js
  end

  # DELETE /admin/sections/1.js
  def destroy
    authorize_action_for @section, at: current_store

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

    # Create columns and segments according to given layout preset.
    def create_columns!
      columns = params[:columns].to_i
      columns.times do |i|
        column = @section.columns.create(priority: i)
        column.segments.create(Segment.default_settings)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.fetch(:section) {{}}.permit(
        :width, :layout, :gutters, :swiper, :viewport,
        :background_color, :fixed_background,
        :gradient_color, :gradient_type, :gradient_direction, :gradient_balance
      )
    end
end
