#encoding: utf-8

class ComponentEntry < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :component, class_name: 'Product'

  default_scope { includes(:component).order('products.title ASC, products.subtitle ASC') }

  #---
  validates :quantity, numericality: {only_integer: true, greater_than: 0}
  validates :component_id, presence: true
end
