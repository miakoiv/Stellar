class ProductUpload < ApplicationRecord

  include Authority::Abilities

  #---
  belongs_to :store
  has_attached_file :attachment

  do_not_validate_attachment_file_type :attachment

  #---
  # Provides a ProductUploader object as specified by store settings.
  def product_uploader
    store.product_uploader_class.new(store: store, file: attachment)
  end

  def to_s
    attachment_file_name
  end
end
