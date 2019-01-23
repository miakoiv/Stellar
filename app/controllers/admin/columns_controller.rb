#encoding: utf-8

class Admin::ColumnsController < AdminController

  before_action :set_column

  authority_actions settings: 'update', modify: 'update'

  # GET /admin/columns/1/settings.js
  def settings
    authorize_action_for @column, at: current_store

    respond_to :js
  end

  # PATCH/PUT /admin/columns/1.js
  def update
    authorize_action_for @column, at: current_store

    respond_to do |format|
      if @column.update(column_params)
        format.js
      else
        format.js { render json: @column.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/columns/1/modify.js
  def modify
    @column.update(column_params)
    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_column
      @column = Column.joins(:section).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def column_params
      params.fetch(:column) {{}}.permit(
        :alignment, :pivot, :background_color
      )
    end
end
