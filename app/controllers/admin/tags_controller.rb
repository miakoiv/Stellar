#encoding: utf-8

class Admin::TagsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/tags
  def index
    authorize_action_for Tag, at: current_store
    @tags = current_store.tags
  end

  # GET /admin/tags/1
  def show
    redirect_to edit_admin_tag_path(@tag)
  end

  # GET /admin/tags/new.js
  def new
    authorize_action_for Tag, at: current_store
    @tag = current_store.tags.build

    respond_to :js
  end

  # GET /admin/tags/1/edit
  # GET /admin/tags/1/edit.js
  def edit
    authorize_action_for @tag, at: current_store
    @tags = current_store.tags

    respond_to :html, :js
  end

  # POST /admin/tags
  # POST /admin/tags.js
  def create
    authorize_action_for Tag, at: current_store
    @tag = current_store.tags.build(tag_params)

    respond_to do |format|
      if @tag.save
        track @tag
        @tags = current_store.tags

        format.html { redirect_to edit_admin_tag_path(@tag), notice: t('.notice', tag: @tag) }
        format.js { flash.now[:notice] = t('.notice', tag: @tag) }
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /admin/tags/1
  # PATCH/PUT /admin/tags/1.js
  def update
    authorize_action_for @tag, at: current_store

    respond_to do |format|
      if @tag.update(tag_params)
        track @tag
        format.html { redirect_to admin_tag_path(@tag), notice: t('.notice', tag: @tag) }
        format.js { flash.now[:notice] = t('.notice', tag: @tag) }
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /admin/tags/1
  def destroy
    authorize_action_for @tag, at: current_store
    track @tag
    @tag.destroy

    redirect_to admin_tags_path, notice: t('.notice', tag: @tag)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = current_store.tags.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(
        :name, :appearance, :searchable
      )
    end
end
