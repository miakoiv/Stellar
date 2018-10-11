#encoding: utf-8

class Image < ActiveRecord::Base

  paginates_per 12

  include Authority::Abilities
  include Trackable

  #---
  has_many :pictures, dependent: :destroy
  belongs_to :store

  has_attached_file :attachment,
    styles: {
      lightbox:       '1920x1200>',
      presentational: '1000x600>',
      technical:      '400x400>',
      postcard:       '300x300>',
      matchbox:       '200x200>',
      thumbnail:      '75x75>',
      icon:           '25x25#',
    },
    convert_options: {
      all:            '-set colorspace sRGB -strip -unsharp 0.25x0.08+8.3+0.045',
      lightbox:       '-quality 80',
      presentational: '-quality 80',
      technical:      '-quality 80',
      postcard:       '-quality 80',
      matchbox:       '-quality 70',
      thumbnail:      '-quality 70',
      icon:           '-quality 70',
    },
    adapter_options: {
      hash_digest: Digest::SHA256
    }
  before_post_process :resize_bitmaps

  default_scope { order(created_at: :desc) }

  delegate :url, to: :attachment

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Aimage/(bmp|jpeg|jpg|png|x-png|svg)},
      ]
    }

  #---
  def is_vector?
    !!(attachment_content_type =~ /\/svg/)
  end

  def is_bitmap?
    !is_vector?
  end

  # Image dimensions courtesy of FastImage, cached.
  def dimensions(style = :original)
    @dimensions ||= {}
    return {} unless is_bitmap? && File.exist?(attachment.path(style))
    @dimensions[style] ||= [:width, :height].zip(FastImage.size(attachment.path(style))).to_h
  end

  def portrait?
    return nil unless is_bitmap?
    dimensions[:height] > dimensions[:width]
  end

  def landscape?
    !portrait?
  end

  def to_s
    attachment_file_name.humanize
  end

  private
    def resize_bitmaps
      return false if is_vector?
    end
end
