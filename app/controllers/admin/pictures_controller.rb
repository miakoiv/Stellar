#encoding: utf-8

class Admin::PicturesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!

  # No layout, this controller never renders HTML.

  # GET /admin/pictureable/1/pictures.js
  def index
    @pictureable = find_pictureable

    # JS response for layout editor, shows
    # the pictures in the editor panel.
    respond_to :js
  end

  # GET /admin/pictures/1
  # This is only called by Dropzone as callback for success.
  def show
    @picture = Picture.find(params[:id])
    @pictureable = @picture.pictureable

    respond_to :js
  end

  # GET /admin/pictureable/1/pictures/new
  def new
    @pictureable = find_pictureable
    @picture = @pictureable.pictures.build(
      purpose: @pictureable.available_purposes.first,
      variant: 'presentational'
    )

    respond_to :js
  end

  # GET /admin/pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])

    respond_to :js
  end

  # POST /admin/pictureable/1/pictures
  def create
    @pictureable = find_pictureable
    @picture = @pictureable.pictures.build(picture_params.merge(priority: @pictureable.pictures.count))

    respond_to do |format|
      if @picture.save
        track @picture, @pictureable
        format.js { render :create }
        format.json { render json: @picture, status: 200 } # for dropzone
      else
        format.js { render :error }
        format.html { render json: {error: t('.error')} }
        format.json { render json: {error: @picture.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # PATCH/PUT /admin/pictures/1
  def update
    @picture = Picture.find(params[:id])
    @pictureable = @picture.pictureable

    respond_to do |format|
      if @picture.update(picture_params)
        track @picture, @pictureable
        format.js { render :update }
      else
        format.js { render :error }
      end
    end
  end

  # DELETE /admin/pictures/1
  def destroy
    @picture = Picture.find(params[:id])
    @pictureable = @picture.pictureable
    track @picture, @pictureable

    respond_to do |format|
      if @picture.destroy
        format.js
      end
    end
  end

  private
    # Finds the associated pictureable by looking through params.
    # Invokes a friendly_id find if the class implements it.
    def find_pictureable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          klass = $1.classify.constantize
          if klass.respond_to?(:friendly)
            association_method = $1.tableize
            return current_store.send(association_method).friendly.find(value)
          else
            return klass.find(value)
          end
        end
      end
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(
        :image_id, :purpose, :variant, :caption, :url
      )
    end
end
