class ProductUploaderJob < ApplicationJob
  queue_as :default

  def perform(product_upload)
    product_upload.product_uploader.process
    product_upload.update(processed_at: Time.now)
  end
end
