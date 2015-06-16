#encoding: utf-8

class ProductImage < ActiveRecord::Base

  belongs_to :product
  has_attached_file :image,
    styles: {large: '1024x1024>', medium: '256x256>', thumb: '64x64>'}


  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

end
