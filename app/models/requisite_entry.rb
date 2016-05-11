#encoding: utf-8

class RequisiteEntry < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :requisite, class_name: 'Product'

  default_scope { includes(:requisite).order(:priority) }

  #---
  validates :requisite_id, presence: true
end
