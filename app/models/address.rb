class Address < ApplicationRecord

  resourcify
  include Authority::Abilities

  belongs_to :country, foreign_key: :country_code

  validates :address1, :postalcode, :city, :country_code, presence: true

  def self.default(store)
    new(country: store.country)
  end

  def empty?
    attributes.except('id', 'country_code').all? { |_, v| v.nil? || v.squish.empty? }
  end

  def to_s
    [name, phone, company, address1, address2, postalcode, city, country].compact.join "\n"
  end
end
