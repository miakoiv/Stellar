class Admin::ProductUploadsController < AdminController

  # GET /admin/product_uploads/1
  # This is only called by Dropzone as callback for success.
  def show
    @product_upload = current_store.product_uploads.find(params[:id])

    head :ok
  end

  # GET /admin/product_uploads/new
  def new
    respond_to :js
  end

  # POST /admin/product_uploads
  def create
    authorize_action_for Product, at: current_store
    @product_upload = current_store.product_uploads.build(product_upload_params)

    respond_to do |format|
      if @product_upload.save
        ProductUploaderJob.perform_later(@product_upload)
        format.json { render json: @product_upload, status: 200 } # for dropzone
      else
        format.json { render json: {error: @product_upload.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_upload_params
    params.require(:product_upload).permit(
      :attachment
    )
  end
end
