#encoding: utf-8

class TaxCategory < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  belongs_to :store

  default_scope { sorted }

  #---
  validates :name, presence: true
  validates :rate, numericality: {greater_than_or_equal_to: 0, less_than: 100}

  #---
  # Convenience method to query tax inclusion at given price base.
  def tax_included?(price_base)
    send("included_in_#{price_base}".to_sym)
  end

  # As of now, cost and trade prices are considered to be sans tax.
  def included_in_cost
    false
  end
  alias_method :included_in_cost?, :included_in_cost

  def included_in_trade
    false
  end
  alias_method :included_in_trade?, :included_in_trade

  def to_s
    name
  end
end
