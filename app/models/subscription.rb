#encoding: utf-8

class Subscription < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  # Store subscribing to the Stripe plan.
  belongs_to :store, required: true

  # Associated customer (user).
  belongs_to :customer, class_name: 'User', required: true

  default_scope { order(first_date: :desc) }

  #---
  # Returns the associated Plan object.
  def plan
    @plan ||= Plan.new(stripe_plan_id: stripe_plan_id)
  end

  def to_s
    stripe_plan.nickname
  end
end
