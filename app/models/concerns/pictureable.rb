module Pictureable
  extend ActiveSupport::Concern

  included do
    has_many :pictures, as: :pictureable, dependent: :destroy
  end

  # Editing options available to pictureables by default,
  # may be overridden on a class by class basis.
  def picture_options
    {purpose: nil, variant: nil}
  end

  def available_purposes
    picture_options[:purpose] || Picture.available_purposes
  end

  def available_variants
    picture_options[:variant] || []
  end

  def cover_picture(purpose = :presentational)
    pictures.send(purpose).first || pictures.presentational.first
  end

  def picture_count
    pictures.count
  end
end
