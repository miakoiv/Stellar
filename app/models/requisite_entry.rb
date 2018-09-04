#encoding: utf-8

class RequisiteEntry < ActiveRecord::Base

  include Reorderable

  belongs_to :product, touch: true, required: true
  belongs_to :requisite, class_name: 'Product', required: true

  default_scope { sorted }
  scope :live, -> { joins(:requisite).merge(Product.live) }
end
