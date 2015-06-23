#encoding: utf-8

class ImageType < ActiveRecord::Base

  has_many :images


  def self.options
    all.map { |i| [i.name, i.id] }
  end


  def to_s
    name
  end
end
