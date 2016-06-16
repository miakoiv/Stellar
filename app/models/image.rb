#encoding: utf-8

class Image < ActiveRecord::Base

  include Reorderable

  enum purpose: {presentational: 0, technical: 1, document: 2, vector: 3}

  #---
  belongs_to :imageable, polymorphic: true, touch: true

  has_attached_file :attachment,
    styles: {
      lightbox: '1000x1000>',
      presentational: '600x600>',
      technical: '400x400>',
      matchbox: '200x200>',
      thumbnail: '75x75>',
      icon: '25x25#',
    },
    convert_options: {
      lightbox: '-strip',
      presentational: '-strip',
      technical: '-strip',
      matchbox: '-strip -quality 75',
      thumbnail: '-strip -quality 70',
      icon: '-strip -quality 70',
    }
  before_post_process :resize_bitmaps
  before_create :assign_purpose

  delegate :url, to: :attachment

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Aimage/(bmp|jpeg|jpg|png|x-png|svg)},
        %r{\Aapplication/(pdf|msword)},
        %r{\Aapplication/vnd.openxmlformats},
      ]
    }

  #---
  # Applicable purposes based on attachment bitmappiness.
  def applicable_purposes
    return ['presentational', 'technical'] if is_bitmap?
    return ['vector'] if is_vector?
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
    when %r{\Aapplication/pdf}
      'file-pdf-o'
    when %r{\Aapplication/(msword|vnd.openxmlformats)}
      'file-word-o'
    else
      'file-o'
    end
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
