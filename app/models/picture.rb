#encoding: utf-8
#
# Pictures are instances of images used in different contexts, connecting
# the images with pictureable objects, and containing metadata about the
# context.
#
class Picture < ApplicationRecord

  include Authority::Abilities
  include Trackable
  include Reorderable

  enum purpose: {presentational: 0, technical: 1}

  #---
  belongs_to :image
  belongs_to :pictureable, polymorphic: true, touch: true

  default_scope { sorted }

  #---
  validates :image, presence: true

  #---
  before_validation :assign_purpose

  #---
  def self.available_purposes
    purposes.keys
  end

  #---
  # Generates a duplicate not attached to any pictureable.
  def duplicate
    dup.tap do |c|
      c.pictureable = nil
    end
  end

  # Assign first available purpose.
  def assign_purpose
    self.purpose ||= Picture.available_purposes.first
  end

  def to_s
    image.attachment_file_name
  end
end
