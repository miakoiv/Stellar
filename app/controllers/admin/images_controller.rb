#encoding: utf-8

class Admin::ImagesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!

  # No layout, this controller never renders HTML.

  # GET /admin/images/1
  # This is only called by Dropzone as callback for success.
  def show
    @image = Image.find(params[:id])
    @imageable = @image.imageable

    respond_to do |format|
      format.js
    end
  end

  # POST /admin/imageable/1/images
  def create
    @imageable = find_imageable
    @image = @imageable.images.build(image_params.merge(priority: @imageable.images.count))

    respond_to do |format|
      if @image.save
        format.json { render json: @image, status: 200 } # for dropzone and summernote
      else
        format.html { render json: {error: t('.error')} }
        format.json { render json: {error: @image.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # PATCH/PUT /admin/images/1
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update(image_params)
        format.js
      end
    end
  end

  # DELETE /admin/images/1
  def destroy
    @image = Image.find(params[:id])
    @imageable = @image.imageable

    respond_to do |format|
      if @image.destroy
        format.js
      end
    end
  end

  private
    # Finds the associated imageable by looking through params.
    # Invokes a friendly_id find if the class implements it.
    def find_imageable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          klass = $1.classify.constantize
          if klass.respond_to?(:friendly)
            return klass.friendly.find(value)
          else
            return klass.find(value)
          end
        end
      end
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(
        :purpose, :attachment
      )
    end
end
