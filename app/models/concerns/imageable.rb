module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, dependent: :destroy
  end

  # Collected images by purpose, useful for preloading.
  def collected_images
    @collection ||= images.includes(:image_type).ordered.group_by { |i| i.image_type.purpose }
  end

  # Use the first presentational image as cover image.
  def cover_image
    images.presentational.ordered.first
  end

  def technical_cover_image
    images.technical.ordered.first
  end
end
