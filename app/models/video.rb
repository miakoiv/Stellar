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

  default_scope { sorted }

  #---
  def to_s
    title
  end
end
