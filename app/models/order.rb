#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  belongs_to :store
  belongs_to :user
  belongs_to :order_type
  has_many :order_items, dependent: :destroy

  # Default scope includes completed, not yet approved orders.
  default_scope { where.not(ordered_at: nil).where(approved_at: nil) }

  # Unordered orders is the scope for shopping carts.
  scope :unordered, -> { unscope(where: :ordered_at).where(ordered_at: nil) }


  def insert!(product, amount)
    order_item = order_items.create_with(amount: 0).find_or_create_by(product: product)
    order_item.amount += amount
    order_item.save
  end

  def to_s
    new_record? ? 'New order' : "[#{created_at.to_s(:long)}] #{user}"
  end
end
