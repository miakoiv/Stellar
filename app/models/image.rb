#encoding: utf-8

class Image < ActiveRecord::Base

  belongs_to :imageable, polymorphic: true
  belongs_to :image_type
  has_attached_file :attachment,
    styles: {large: '1024x1024>', medium: '256x256>', thumb: '64x64>'}


  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/

end
