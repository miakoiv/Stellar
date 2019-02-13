#
# Plan is a wrapper for Stripe::Plans::Configuration objects,
# initialized by specifying a stripe_plan_id attribute that
# matches one of the configurations in config/stripe/plans.rb.
#
class Plan

  include ActiveModel::Model
  extend ActiveModel::Translation

  attr_reader :config
  attr_writer :stripe_plan_id

  #---
  def self.i18n_scope
    :activerecord
  end

  def self.all
    @all ||= Stripe::Plans.configurations.keys.map { |k|
      new(stripe_plan_id: k)
    }
  end

  #---
  def initialize(attributes = {})
    super
    @config = Stripe::Plans[@stripe_plan_id]
    raise ArgumentError if @config.nil?
  end

  def id
    @config.id
  end

  def amount
    Money.new(@config.amount, @config.currency)
  end

  def interval
    @config.interval
  end

  def interval_count
    @config.interval_count
  end

  def trial_period_days
    @config.trial_period_days
  end

  def nickname
    @config.nickname
  end

  def to_s
    nickname
  end
end
