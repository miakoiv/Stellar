class OrderType < ApplicationRecord

  MESSAGE_STAGES = %w{acknowledge processing confirmation notification receipt conclusion cancellation
  }.freeze

  resourcify
  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  belongs_to :store

  # Source and destination reference groups to define the workflow
  # for orders of this type.
  belongs_to :source, class_name: 'Group', inverse_of: :outgoing_order_types
  belongs_to :destination, class_name: 'Group', inverse_of: :incoming_order_types

  # Orders are destroyed along with their order type, but see below.
  # Order types should never be destroyed if completed orders exist.
  has_many :orders, dependent: :destroy

  # Message definitions attached to this order type, if any.
  has_many :messages, as: :context

  default_scope { sorted }
  scope :has_shipping, -> { where(has_shipping: true) }

  #---
  validates :payment_gateway, presence: true, if: -> { has_billing? }

  #---
  def payment_gateway
    return 'None' unless has_billing?
    super
  end

  def payment_gateway_class
    gateway_class ||= "PaymentGateway::#{payment_gateway}".constantize
  end

  def message_stages
    MESSAGE_STAGES
  end

  # Checks if any completed orders refer to this order type, cancelled
  # or not. Used by the authorizer to check against deletion.
  def has_any_orders?
    orders.complete.unscope(where: :cancelled_at).any?
  end

  def to_s
    name
  end
end
