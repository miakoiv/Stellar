#encoding: utf-8

class ImageType < ActiveRecord::Base

  enum purpose: {presentational: 0, technical: 1, document: 2}

  #---
  has_many :images

  #---
  def self.options
    all.map { |i| [i.name, i.id] }
  end

  #---
  def to_s
    name
  end
end
