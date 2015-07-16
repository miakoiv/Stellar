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

  # Approved orders.
  scope :approved, -> { unscope(where: :approved_at).where.not(approved_at: nil) }


  def approval
    !!approved_at.present?
  end

  # Setting approval status also archives the order and its order items.
  def approval=(status)
    case status
    when '1'
      archive!
      update(approved_at: Time.current)
    when '0'
      update(approved_at: nil)
    else
      raise "Unknown approval status #{status}"
    end
  end

  def insert!(product, amount)
    order_item = order_items.create_with(amount: 0).find_or_create_by(product: product)
    order_item.amount += amount
    order_item.save
  end

  def to_s
    new_record? ? 'New order' : ("%08d" % id)
  end

  private
    def archive!
      transaction do
        update(
          store_name: store.name,
          store_contact_person_name: store.contact_person.name,
          store_contact_person_email: store.contact_person.email,
          user_name: user.name,
          user_email: user.email,
          order_type_name: order_type.name
        )
        order_items.each do |item|
          item.archive!
        end
      end
    end
end
