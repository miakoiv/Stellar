#encoding: utf-8

class Subscription < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  enum status: {active: 0, cancelling: 1, cancelled: 2}

  #---
  # Store subscribing to the Stripe plan.
  belongs_to :store, required: true

  # Associated customer (user).
  belongs_to :customer, class_name: 'User', required: true

  default_scope { order(created_at: :desc) }
  scope :running, -> { where.not(status: 2)}

  #---
  # New subscriptions have this set by Stripe Checkout.
  attr_accessor :stripe_source_id

  #---
  # Returns the associated Plan object.
  def plan
    @plan ||= Plan.new(stripe_plan_id: stripe_plan_id)
  end

  def running?
    !cancelled?
  end

  def appearance
    running? ? 'primary' : 'default'
  end

  def to_s
    "%s–%s" % [
      first_date.presence && I18n.l(first_date),
      last_date.presence && I18n.l(last_date)
    ]
  end
end
