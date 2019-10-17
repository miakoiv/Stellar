class Admin::VideosController < AdminController

  include Reorderer

  # GET /admin/videoable/1/videos.js
  def index
    @videoable = find_videoable

    # JS response for layout editor, shows
    # the videos in the editor panel.
    respond_to :js
  end

  # POST /admin/videoable/1/videos
  def create
    @videoable = find_videoable
    @video = @videoable.videos.build(video_params.merge(priority: @videoable.videos.count))

    respond_to do |format|
      if @video.save
        track @video, @videoable
        format.js { render :create }
      end
    end
  end

  # PATCH/PUT /admin/videos/1
  def update
    @video = Video.find(params[:id])
    @videoable = @video.videoable

    respond_to do |format|
      if @video.update(video_params)
        track @video, @videoable
        format.js { render :update }
      end
    end
  end

  # DELETE /admin/videos/1
  def destroy
    @video = Video.find(params[:id])
    @videoable = @video.videoable
    track @video, @videoable

    respond_to do |format|
      if @video.destroy
        format.js
      end
    end
  end

  private

  # Finds the associated videoable by looking through params.
  def find_videoable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        klass = $1.classify.constantize
        return klass.find(value)
      end
    end
    nil
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def video_params
    params.fetch(:video, {}).permit(
      :title, :loop, :muted
    )
  end
end
