module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable
  end

  # Use the first presentational image as cover image.
  def cover_image
    images.by_type(:presentational).first
  end

  # Use an icon if found, otherwise the cover image.
  def icon_image
    images.by_type(:icon).first || cover_image
  end
end
