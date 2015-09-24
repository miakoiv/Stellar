#encoding: utf-8

class ImageType < ActiveRecord::Base

  enum purpose: {presentational: 0, technical: 1, document: 2}

  #---
  has_many :images

  #---
  def to_s
    human_attribute_value(:purpose)
  end
end
