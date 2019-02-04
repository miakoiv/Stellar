#encoding: utf-8

class Admin::SegmentsController < AdminController

  include Reorderer

  before_action :set_segment, only: [:show, :edit, :settings, :update, :modify, :copy, :destroy]

  authority_actions reorder: 'update', paste: 'create'

  # GET /admin/segments/1.js
  def show
    @page = @segment.column.section.page

    respond_to :js
  end

  # GET /admin/segments/1/edit.js
  def edit
    respond_to do |format|
      format.js { render @segment.edit_in_place? ? :edit_in_place : :edit }
    end
  end

  # GET /admin/segments/1/settings.js
  def settings
    respond_to :js
  end

  # POST /admin/columns/1/segments.js
  def create
    @column = Column.find(params[:column_id])
    authorize_action_for @column, at: current_store
    @segment = @column.segments.build(
      segment_params
        .merge(Segment.default_settings)
        .merge(priority: @column.segments.count)
    )
    respond_to do |format|
      if @segment.save
        track @segment, @segment.column.section.page
        format.js { render :create }
      else
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/segments/1.js
  def update
    authorize_action_for @segment, at: current_store
    @page = @segment.column.section.page
    @content_mode = params[:content_mode].presence
    in_place_edit = params[:in_place_edit].presence

    respond_to do |format|
      if @segment.update(segment_params)
        track @segment, @page
        @segment.touch
        format.js { render in_place_edit ? :show : :update }
      else
        format.js { render :rollback }
      end
    end
  end

  # PATCH/PUT /admin/segments/1/modify.js
  def modify
    @segment.update(segment_params)
    respond_to :js
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

  # GET /admin/segments/1/copy.json
  def copy
    respond_to :json
  end

  # POST /admin/columns/1/segments/paste.js
  def paste
    @column = Column.find(params[:column_id])
    authorize_action_for @column, at: current_store
    @segment = @column.segments.build(
      segment_attributes.merge(priority: @column.segments.count)
    )
    respond_to do |format|
      if @segment.save
        track @segment, @segment.column.section.page, {action: :create}
        format.js { render :create }
      else
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/segments/1.js
  def destroy
    authorize_action_for @segment, at: current_store
    track @segment, @segment.column.section.page

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
        :template, :alignment, :justification,
        :shape, :inset, :foreground_color, :background_color,
        :body, :header, :subhead, :url,
        :margin_top, :margin_bottom, :min_height,
        :grid_columns, :grid_lines, :grid_disable_xs,
        :masonry, :image_sizing, :thumbnails, :lightbox,
        :max_items, :product_scope, :show_more,
        :map_location, :map_marker, :map_zoom, :map_theme,
        :content_class, :content_type,
        :facebook_page, :facebook_token,
        :inverse, :jumbotron, :shadow,
        :animation, :velocity
      )
    end

    def segment_attributes
      params.require(:segment).permit!
    end
end
