module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, dependent: :destroy
  end

  def cover_image(purpose = :presentational)
    images.send(purpose).first
  end
end
