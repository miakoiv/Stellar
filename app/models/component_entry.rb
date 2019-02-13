class ComponentEntry < ApplicationRecord

  include Reorderable

  belongs_to :product, touch: true
  belongs_to :component, class_name: 'Product', required: true

  default_scope { sorted }
  scope :live, -> { joins(:component).merge(Product.live) }

  #---
  validates :quantity, numericality: {only_integer: true, greater_than: 0}

  #---
  # Availability of the component in the context of this entry.
  def available(inventory)
    component.available(inventory, nil) / quantity
  end

  def to_s
    component.to_s
  end
end
