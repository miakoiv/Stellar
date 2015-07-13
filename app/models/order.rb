#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include ActiveModel::Serialization

  belongs_to :store
  belongs_to :user
  belongs_to :order_type
  has_many :order_items, dependent: :destroy

  # Default scope includes completed, not yet approved orders.
  default_scope { where.not(ordered_at: nil).where(approved_at: nil) }

  # Unordered orders is the scope for shopping carts.
  scope :unordered, -> { unscope(where: :ordered_at).where(ordered_at: nil) }

  # Archived orders have been approved.
  scope :archived, -> { unscope(where: :approved_at).where.not(approved_at: nil) }


  def approval
    !!approved_at.present?
  end

  # Setting approval status also updates
  # the archived copy in JSON format.
  def approval=(status)
    case status
    when '1'
      archive!
      update(approved_at: Time.current)
    when '0'
      unarchive!
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

  def as_json(options = {})
    super(
      only: [
        :ordered_at, :approved_at, :company_name, :contact_person,
        :billing_address, :shipping_address, :notes
      ],
      include: {
        store: {
          only: :name,
          include: {
            contact_person: {
              only: [:name, :email]
            }
          }
        },
        user: {
          only: [:name, :email]
        },
        order_items: {
          only: :amount,
          include: {
            product: {
              only: [:code, :customer_code, :title, :subtitle, :sales_price]
            }
          }
        }
      }
    )
  end

  private
    def archive!
      update(archived_copy: to_json)
    end

    def unarchive!
      update(archived_copy: nil)
    end

end
