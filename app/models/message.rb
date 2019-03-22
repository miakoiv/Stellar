#
# Messages model the e-mail that is sent from order and shipment
# workflows at predefined stages like order confirmation or shipment
# completion. Messages are associated with a context that may be
# an order type or a shipment method, and specify the stage they are
# sent at, as well as the message content.
#
class Message < ApplicationRecord

  STAGES = %w{acknowledge processing confirmation notification receipt conclusion cancellation shipment
  }.freeze

  resourcify
  include Authority::Abilities
  include Trackable

  #---
  belongs_to :store
  belongs_to :context, polymorphic: true

  default_scope { order(:context_type, :context_id, :stage) }

  validates :context, presence: true
  validates :stage, presence: true, uniqueness: {scope: :context}

  #---
  def self.stage_options
    STAGES
  end

  #---
  def context_gid
    context ? context.to_global_id.to_s : nil
  end

  def context_gid=(gid)
    self.context = GlobalID::Locator.locate(gid)
  end

  def to_s
    [context, Message.human_attribute_value(:stage, stage)].join ' '
  end
end
