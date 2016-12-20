#encoding: utf-8

class Store < ActiveRecord::Base

  store :settings, accessors: [
    :locale,   # see #locale_options for supported locales
    :theme,    # see app/stylesheets/spry_themes
    :brand_image, # additional branding image displayed in the footer
    :wiselinks,   # boolean, use wiselinks for storefront navigation
    :masonry,     # boolean, use masonry in storefront products view
    :inline_iframes,  # boolean, render iframes inline (instead of popups)
    :card_image_type, # image purpose to use for cover images on cards etc.
    :list_image_type, # image purpose in list views
    :allow_shopping,  # boolean, master switch to allow/disallow shopping
    :b2b_sales,       # boolean, does the shop do business to business sales
    :global_sales,    # boolean, do shipping addresses include country selection
    :admit_guests,    # boolean, are guests allowed to shop at the store
    :accept_credit_cards,  # boolean, are credit cards accepted as payment method
    :tracking_code,   # Google Analytics code
    :tawkto_site_id, # tawk.to site id for chat widget
    :pbw_api_key,     # Paybyway API key
    :pbw_private_key, # Paybyway private key
    :order_sequence, # base value for order numbers if no numbering exists
    :manufacturer_template_id, # page references to templates
    :reseller_template_id,
    :quotation_template_id,
    :csv_encoding,        # CSV encoding of uploaded files
    :csv_product_code,    # CSV field headers for product code,
    :csv_retail_price,    # retail price, and inventory amount
    :csv_inventory_amount # in uploaded files
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Imageable

  #---
  after_create :assign_slug

  #---
  # Home country, used as default shipping and billing country.
  belongs_to :country, foreign_key: :country_code

  # A store has one or more hostnames it can be found at.
  has_many :hostnames, as: :resource, dependent: :destroy

  # A store may appear at multiple portals.
  has_and_belongs_to_many :portals

  # All these associations are dependent of the store.
  with_options dependent: :destroy do |store|
    store.has_many :inventories
    store.has_many :categories
    store.has_many :products
    store.has_many :properties
    store.has_many :orders
    store.has_many :order_types
    store.has_many :shipping_methods
    store.has_many :pages
    store.has_many :albums
    store.has_many :promotions
    store.has_many :users
    store.has_many :customer_assets
    store.has_many :pricing_groups
    store.has_many :tax_categories
  end

  has_many :inventory_items, through: :inventories
  has_many :shipping_cost_products, through: :shipping_methods

  accepts_nested_attributes_for :users, limit: 1
  accepts_nested_attributes_for :tax_categories, limit: 1

  scope :all_except, -> (this) { where.not(id: this) }

  #---
  validates :name, presence: true
  validates :country, presence: true
  validates :erp_number, numericality: true, allow_blank: true

  #---
  # The minimal set of default settings for a newly created store.
  def self.default_settings
    {
      brand_image: 'leasit.svg',
      card_image_type: 'presentational',
      list_image_type: 'presentational'
    }
  end

  def self.locale_options
    @@locale_options ||= [['English', 'en'], ['Deutsch', 'de'], ['suomi', 'fi']]
  end

  # Looks up the names of precompiled stylesheets for themes.
  def self.theme_options
    @@themes ||= Rails.application.config.assets.precompile.select { |a|
      a.is_a?(String) && a.sub!(/spry_themes\/([^.]+)\.css/, "\\1")
    }
  end

  # Options for shipping gateways found in the ShippingGateway module.
  def self.shipping_gateway_options
    Shipment.available_gateways.map do |gateway|
      ["ShippingGateway::#{gateway}".constantize.model_name.human, gateway]
    end
  end

  # Options for shipping address countries.
  def self.country_options
    @@country_options ||= Country.all.map { |c| [c.name, c.code] }
  end

  #---
  # Defaults for guest users reveal pricing and stock, and will allow shopping
  # if admit_guests is also enabled, to get in without authentication.
  def guest_user_defaults(host)
    name = "#{Time.now.to_i}#{rand(100)}"
    {
      name: name,
      email: "#{name}@#{host}",
      group: User.groups[:guest],
      roles: Role.where(name: %w[see_pricing see_stock])
    }
  end

  # Tries to find a subdomain hostname for this store at given domain,
  # defaulting to any hostname at all.
  def hostname_at(domain)
    hostnames.subdomain.at(domain).first || hostnames.first
  end

  # Returns the first hostname for mailers and such with no request context.
  def primary_host
    hostnames.first
  end

  # Properties flagged searchable.
  def searchable_properties
    properties.merge(Property.searchable).merge(Property.sorted)
  end

  # Available categories at top level.
  def top_level_category_options(exclude = nil)
    (categories.top_level - [exclude]).map { |c| [c.name, c.id] }
  end

  # Countries where concluded orders have been shipped to.
  # Useful as sales report search option.
  def countries_shipped_to
    country_codes = orders.concluded.select(:shipping_country_code)
      .distinct.pluck(:shipping_country_code)
    Country.find(country_codes)
  end

  def user_options
    users.map { |u| [u.to_s, u.id] }
  end

  def album_options
    albums.map { |a| [a.to_s, a.id] }
  end

  def template_options
    pages.template.map { |p| [p.to_s, p.id] }
  end

  # Defines accessors to boolean settings not generated by Rails.
  %w[wiselinks masonry inline_iframes allow_shopping admit_guests
      accept_credit_cards b2b_sales global_sales].each do |method|
    alias_method "#{method}?", method
    define_method("#{method}=") do |value|
      super(['1', 1, true].include?(value))
    end
  end

  def correspondents
    users.with_role(:correspondence)
  end

  # Serves the contents of the letterhead template for given user.
  def letterhead(user)
    page_id = send("#{user.group}_template_id")
    return '' unless page_id.present?
    pages.find(page_id).content
  end

  # Quotation boilerplate is the template page contents.
  def quotation_boilerplate
    return '' unless quotation_template_id.present?
    pages.find(quotation_template_id).content
  end

  # CSV header conversion table for uploaded products.
  def csv_headers
    {
      csv_product_code => :product_code,
      csv_retail_price => :retail_price,
      csv_inventory_amount => :inventory_amount
    }
  end

  def csv_options
    {
      col_sep: ';',
      encoding: csv_encoding || 'utf-8',
      headers: true
    }
  end

  def to_s
    name
  end

  def description
    nil
  end

  private
    def assign_slug
      taken_slugs = Store.all_except(self).map(&:slug)
      len = 3
      unique_slug = "#{name}#{id}#{Time.now.to_i}"
        .parameterize.underscore.mb_chars.downcase
      begin
        slug = unique_slug[0, len]
        len += 1
      end while taken_slugs.include?(slug)
      update(slug: slug)
    end
end
