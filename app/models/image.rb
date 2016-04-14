#encoding: utf-8

class Image < ActiveRecord::Base

  include Reorderable

  #---
  belongs_to :imageable, polymorphic: true, touch: true
  belongs_to :image_type
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
  before_create :assign_image_type

  ImageType.purposes.keys.each do |purpose|
    scope purpose, -> { joins(:image_type).merge(ImageType.send(purpose)) }
  end

  delegate :url, to: :attachment

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Aimage/(bmp|jpeg|jpg|png|x-png)},
        %r{\Aapplication/(pdf|msword)},
        %r{\Aapplication/vnd.openxmlformats},
      ]
    }

  #---
  # Finds an image by its url, because Froala doesn't know about ids.
  def self.at_url(url, size = :original)
    all.find { |i| i.url(size, false) == url }
  end

  #---
  # Applicable image types due to attachment bitmappiness.
  def applicable_image_types
    ImageType.where(bitmap: is_bitmap?)
  end

  # Assign first applicable image type.
  def assign_image_type
    self.image_type = applicable_image_types.first
  end

  def is_bitmap?
    !!(attachment_content_type =~ /\Aimage/)
  end

  # The style given to Froala is lightbox sized for bitmaps,
  # original for documents and other non-bitmaps.
  def froala_style
    is_bitmap? ? :lightbox : :original
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

  private
    def resize_bitmaps
      return false unless is_bitmap?
    end
end
