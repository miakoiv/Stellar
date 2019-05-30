class VideoFile < ApplicationRecord

  belongs_to :video
  has_attached_file :attachment

  default_scope { order(created_at: :desc) }

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Avideo/(mp4|ogg|webm)},
      ]
    }

  #---
  def url
    attachment.url(:original, timestamp: false)
  end

  def content_type
    attachment_content_type
  end

  def to_s
    attachment_file_name.humanize
  end
end
