#encoding: utf-8

class RequisiteEntry < ActiveRecord::Base

  include Reorderable

  belongs_to :product, touch: true
  belongs_to :requisite, class_name: 'Product'

  default_scope { sorted }
  scope :live, -> { joins(:requisite).merge(Product.live) }

  #---
  validates :requisite_id, presence: true
end
