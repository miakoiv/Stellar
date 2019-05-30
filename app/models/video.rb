#
# Videos are containers for video files that can be attached to
# anything videoable.
#
class Video < ApplicationRecord

  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  belongs_to :videoable, polymorphic: true
  has_many :video_files, dependent: :destroy

  default_scope { sorted }

  #---
  def to_s
    title
  end
end
