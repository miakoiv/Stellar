#encoding: utf-8

class Relationship < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :component, class_name: 'Product'

end
