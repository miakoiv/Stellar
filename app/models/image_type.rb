#encoding: utf-8

class ImageType < ActiveRecord::Base

  has_many :images

  enum purpose: {presentational: 0, technical: 1, document: 2}

  #---
  def self.options
    all.map { |i| [i.name, i.id] }
  end

  #---
  def to_s
    name
  end
end
