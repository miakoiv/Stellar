#encoding: utf-8
#
# Pictures are instances of images used in different contexts, connecting
# the images with pictureable objects, and containing metadata about the
# context.
#
class Picture < ActiveRecord::Base

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
  # Assign first available purpose.
  def assign_purpose
    self.purpose ||= Picture.available_purposes.first
  end
end
