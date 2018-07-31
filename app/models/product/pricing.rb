class Product < ActiveRecord::Base

  # Monetize product attributes.
  monetize :cost_price_cents, allow_nil: true
  monetize :trade_price_cents, allow_nil: true
  monetize :retail_price_cents, allow_nil: true

  # Products must have a tax category
  belongs_to :tax_category, required: true

  # Alternate prices for different groups.
  has_many :alternate_prices, dependent: :destroy

  has_many :promoted_items, dependent: :destroy
  has_many :promotions, through: :promoted_items

  def live_promotions(group)
    promotions.merge(Promotion.live)
  end

  def live_promoted_items(group)
    promoted_items.joins(:promotion)
      .merge(Promotion.live)
      .where(promotions: {group_id: group})
  end

  # Finds the promoted item with the lowest quoted price.
  def best_promoted_item(group)
    live_promoted_items(group)
      .where.not(price_cents: nil)
      .order(:price_cents)
      .first
  end

  # Finds the quantity in base units for unit pricing.
  def pricing_quantity_and_unit
    product_property = unit_pricing_property
    return nil if product_property.nil? || product_property.value.nil?
    unit = product_property.property.measurement_unit
    quantity = product_property.value_f * unit.factor
    [quantity, unit.pricing_base]
  end

  def trade_price_with_tax
    return nil if trade_price.nil?
    Price.new(trade_price, tax_category.included_in_trade?, tax_category.rate).with_tax
  end

  # Markup percentage from trade price to retail price.
  def markup_percent
    return nil if trade_price.nil? || retail_price.nil? || trade_price == 0
    if tax_category.included_in_retail?
      100 * (retail_price - trade_price_with_tax) / trade_price_with_tax
    else
      100 * (retail_price - trade_price) / trade_price
    end
  end

  # Margin percentage from trade price to retail price.
  def margin_percent
    return nil if trade_price.nil? || retail_price.nil? || retail_price == 0
    if tax_category.included_in_retail?
      100 * (retail_price - trade_price_with_tax) / retail_price
    else
      100 * (retail_price - trade_price) / retail_price
    end
  end

  private
    def unit_pricing_property
      product_properties.joins(:property).merge(Property.unit_pricing).first
    end
end
