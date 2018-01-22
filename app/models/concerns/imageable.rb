module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, dependent: :destroy
  end

  # Editing options available to imageables by default,
  # may be overridden on a class by class basis.
  def image_options
    {purpose: nil}
  end

  def available_purposes
    image_options[:purpose] || Image.available_purposes
  end

  def cover_image(purpose = :presentational)
    images.send(purpose).first || images.presentational.first
  end
end
