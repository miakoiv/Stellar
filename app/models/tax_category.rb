class TaxCategory < ApplicationRecord

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
  def self.defaults_for_locale(locale)
    {
      name: "%s %d%%" % [TaxCategory.human_attribute_name(:default_tax_name, locale: locale), Price::DEFAULT_TAX_RATE],
      rate: Price::DEFAULT_TAX_RATE,
      included_in_retail: true
    }
  end

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
