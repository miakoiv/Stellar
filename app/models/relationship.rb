#encoding: utf-8

class Relationship < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :component, class_name: 'Product'

  #---
  validates :quantity, numericality: {only_integer: true, greater_than: 0}
  validates :component_id, presence: true
end
