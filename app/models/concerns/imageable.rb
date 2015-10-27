module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, dependent: :destroy
  end

  # Use the first presentational image as cover image.
  def cover_image
    images.by_purpose(:presentational).ordered.first
  end

  def technical_cover_image
    images.by_purpose(:technical).ordered.first
  end
end
