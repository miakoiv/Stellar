#encoding: utf-8

class Admin::ImagesController < ApplicationController

  include Reorderer

  # No layout, this controller never renders HTML.

  # GET /admin/images/1
  # This is only called by Dropzone as callback for success.
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  # POST /admin/imageable/1/images
  def create
    @imageable = find_imageable
    @image = @imageable.images.build(image_params)

    respond_to do |format|
      if @image.save
        format.json { render json: @image, status: 200 }
      else
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

    respond_to do |format|
      if @image.destroy
        format.js
      end
    end
  end

  private
    # Finds the associated imageable by looking through params.
    def find_imageable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(
        :image_type_id, :attachment
      )
    end
end
