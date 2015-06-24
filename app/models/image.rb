#encoding: utf-8

class Image < ActiveRecord::Base

  belongs_to :imageable, polymorphic: true
  belongs_to :image_type
  has_attached_file :attachment,
    styles: {
      lightbox: '1024x1024>',
      thumbnail: '128x128>',
      icon: '32x32>',
    }

  scope :icons, -> { joins(:image_type).where(image_types: {name: 'Icon'}) }


  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/

end
