#encoding: utf-8

class Order < ActiveRecord::Base

  belongs_to :user
  belongs_to :order_type
  has_many :order_items

  scope :pending, -> { where(ordered_at: nil) }


  def insert!(product, amount)
    order_item = order_items.create_with(amount: 0).find_or_create_by(product: product)
    order_item.amount += amount
    order_item.save
  end

  def to_s
    new_record? ? 'New order' : "[#{created_at.to_s(:long)}] #{user}"
  end
end
