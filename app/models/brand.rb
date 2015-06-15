#encoding: utf-8

class Brand < ActiveRecord::Base

  has_many :products


  def self.options
    all.map { |b| [b.name, b.id] }
  end


  def to_s
    name
  end
end
