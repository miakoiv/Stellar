#encoding: utf-8

class Admin::AlbumsController < ApplicationController

  before_action :authenticate_user!

  layout 'admin'

  authorize_actions_for Album
  before_action :set_album, only: [:show, :edit, :update, :destroy]

  # GET /admin/albums
  # GET /admin/albums.json
  def index
    @albums = current_store.albums
  end

  # GET /admin/albums/1
  # GET /admin/albums/1.json
  def show
  end

  # GET /admin/albums/new
  def new
    @album = current_store.albums.build
  end

  # GET /admin/albums/1/edit
  def edit
  end

  # POST /admin/albums
  # POST /admin/albums.json
  def create
    @album = current_store.albums.build(album_params)

    respond_to do |format|
      if @album.save
        format.html { redirect_to edit_admin_album_path(@album),
          notice: t('.notice', album: @album) }
        format.json { render :show, status: :created, location: admin_album_path(@album) }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/albums/1
  # PATCH/PUT /admin/albums/1.json
  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to admin_album_path(@album),
          notice: t('.notice', album: @album) }
        format.json { render :show, status: :ok, location: admin_album_path(@album) }
      else
        format.html { render :edit }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/albums/1
  # DELETE /admin/albums/1.json
  def destroy
    @album.destroy
    respond_to do |format|
      format.html { redirect_to admin_albums_path,
        notice: t('.notice', album: @album) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def album_params
      params.require(:album).permit(
        :title, :description, page_ids: []
      )
    end
end
