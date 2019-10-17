class Admin::VideoFilesController < AdminController

  # GET /admin/video_files/1
  # This is only called by Dropzone as callback for success.
  def show
    @video_file = VideoFile.find(params[:id])
    @video = @video_file.video

    respond_to :js
  end

  # POST /admin/videos/1/video_files
  def create
    @video = Video.find(params[:video_id])
    @video_file = @video.video_files.build(video_file_params)

    respond_to do |format|
      if @video_file.save
        format.json { render json: @video_file, status: 200 } # for dropzone
      else
        format.json { render json: {error: @video_file.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # DELETE /admin/video_files/1
  def destroy
    @video_file = VideoFile.find(params[:id])
    @video_file.destroy

    respond_to :js
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def video_file_params
    params.require(:video_file).permit(
      :attachment
    )
  end
end
