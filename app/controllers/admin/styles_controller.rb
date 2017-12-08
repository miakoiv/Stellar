class Admin::StylesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_store

  # No layout, this controller never renders HTML.

  # GET /admin/stores/1/style.js
  def edit
    @style = @store.style || @store.build_style

    respond_to :js
  end

  # POST /admin/styles/1/style.js
  def create
    @style = @store.build_style(style_params)

    respond_to do |format|
      if @style.save
        format.js
      else
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/stores/1/style.js
  def update
    @style = @store.style

    respond_to do |format|
      if @style.update(style_params)
        format.js
      else
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/stores/1/style.js
  def destroy
    @style = @store.style
    @style.destroy

    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:store_id])
    end

  # Never trust parameters from the scary internet, only allow the white list through.
    def style_params
      params.require(:style).permit(
        :preamble, Style::VARIABLES.keys
      )
    end
end
