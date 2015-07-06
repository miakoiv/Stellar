#encoding: utf-8

class Relationship < ActiveRecord::Base

  belongs_to :parent, class_name: 'Product'
  belongs_to :product

end
