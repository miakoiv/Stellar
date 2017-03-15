#encoding: utf-8

class Image < ActiveRecord::Base

  include Reorderable

  enum purpose: {presentational: 0, technical: 1, document: 2, vector: 3, video: 4}

  #---
  belongs_to :imageable, polymorphic: true, touch: true

  default_scope { sorted }

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
    }
  before_post_process :resize_bitmaps
  before_create :assign_purpose

  delegate :url, to: :attachment

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Aimage/(bmp|jpeg|jpg|png|x-png|svg)},
        %r{\Avideo/(mp4|webm)},
        %r{\Aapplication/(pdf|msword)},
        %r{\Aapplication/vnd.openxmlformats},
      ]
    }

  #---
  # Applicable purposes based on attachment bitmappiness.
  def applicable_purposes
    return ['presentational', 'technical'] if is_bitmap?
    return ['vector'] if is_vector?
    return ['video'] if is_video?
    ['document']
  end

  # Assign first applicable purpose.
  def assign_purpose
    self.purpose ||= applicable_purposes.first
  end

  def is_bitmap?
    !!(attachment_content_type =~ /\/(bmp|jpeg|jpg|png|x-png)/)
  end

  def is_vector?
    !!(attachment_content_type =~ /\/svg/)
  end

  def is_video?
    !!(attachment_content_type =~ /video\//)
  end

  # The style given to Summernote is lightbox sized for bitmaps,
  # original for documents and other non-bitmaps.
  def wysiwyg_style
    is_bitmap? ? :lightbox : :original
  end

  def wysiwyg_url
    url(wysiwyg_style, false)
  end

  def document_icon
    case attachment_content_type
    when %r{\Avideo/}
      'file-video-o'
    when %r{\Aapplication/pdf}
      'file-pdf-o'
    when %r{\Aapplication/(msword|vnd.openxmlformats)}
      'file-word-o'
    else
      'file-o'
    end
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

  def as_json(options = {})
    super(methods: [:wysiwyg_url])
  end

  private
    def resize_bitmaps
      return false unless is_bitmap?
    end
end
