#encoding: utf-8

class ComponentEntry < ActiveRecord::Base

  include Reorderable

  belongs_to :product, touch: true
  belongs_to :component, class_name: 'Product'

  default_scope { sorted }
  scope :live, -> { joins(:component).merge(Product.live) }

  #---
  validates :product_id, presence: true
  validates :component_id, presence: true
  validates :quantity, numericality: {only_integer: true, greater_than: 0}

  #---
  # Availability of the component in the context of this entry.
  def available(inventory)
    component.available(inventory, nil) / quantity
  end
end
