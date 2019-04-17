class Address < ApplicationRecord

  NONVALUE_ATTRIBUTES = %w{id created_at updated_at}.freeze

  resourcify
  include Authority::Abilities

  belongs_to :country, foreign_key: :country_code

  validates :address1, :postalcode, :city, :country_code, presence: true

  def self.default(store)
    new(country: store.country)
  end

  def ==(other)
    return false unless other&.respond_to?(:value_attributes)
    value_attributes == other.value_attributes
  end

  def empty?
    attributes.except('id', 'country_code').all? { |_, v| v.blank? }
  end

  def value_attributes
    attributes.except(*NONVALUE_ATTRIBUTES)
  end

  def copy_from(other)
    self.attributes = other.value_attributes
  end

  def to_location
    [company, address1, address2, postalcode, city, country].reject(&:blank?).join ', '
  end

  def to_identifier
    [company, name, city].reject(&:blank?).join ' '
  end

  def to_s
    [company, name, address1, address2, postalcode, city, country, phone].reject(&:blank?).join "\n"
  end
end
