class Store < ApplicationRecord

  store :settings, accessors: [
    :locale,   # see #locale_options for supported locales
    :main_nav_lookup, # boolean, enable lookup widget in main navbar
    :detach_menu, # boolean, detach the primary navigation as #page-menu
    :masonry,     # boolean, use masonry in storefront products view
    :fancy_cart,  # boolean, use modernized shopping cart view
    :cart_promotion,  # boolean, show a promotion section in cart view
    :favorites,   # boolean, enable favorite products
    :category_order,  # boolean, category order view enabled
    :inline_iframes,  # boolean, render iframes inline (instead of popups)
    :card_image_type, # image purpose to use for cover images on cards etc.
    :list_image_type, # image purpose in list views
    :b2b_sales,       # boolean, does the shop do business to business sales
    :global_sales,    # boolean, do shipping addresses include country selection
    :admit_guests,    # boolean, are guests allowed to shop at the store
    :disable_mail,    # boolean, disable all sending of mail
    :custom_smtp_settings, # boolean, enable custom smtp settings, see below
    :disable_shipment_transfers, # boolean, disable transfers for shipments
    :tracking_code,   # Google Analytics code
    :maps_api_key,    # Google Maps API key
    :facebook_access_token,  # Facebook API key
    :facebook_pixel_id, # Facebook Pixel id
    :tawkto_site_id, # tawk.to site id for chat widget
    :pbw_api_key,     # Paybyway API key
    :pbw_private_key, # Paybyway private key
    :oikotie_asunnot_api_key,     # Oikotie Asunnot API key
    :oikotie_asunnot_broker_id,   # Oikotie Asunnot broker company id
    :order_sequence, # base value for order numbers if no numbering exists
    :quotation_template_id, # page reference to quotation boilerplate
    :csv_encoding,         # CSV encoding of uploaded files
    :csv_product_code,     # CSV field headers for product code,
    :csv_trade_price,      # trade price,
    :csv_retail_price,     # retail price, and
    :csv_inventory_amount, # inventory amount
    :order_xml_path,  # where to upload XML files of completed orders
    :shipping_origin, # geolocation-compatible origin for shipping calculations
  ], coder: JSON

  # SMTP settings to override ActionMailer::Base.smtp_settings
  # when enable_smtp_settings is set.
  store :smtp_settings, accessors: [
    :smtp_address, :smtp_port,
    :smtp_user_name, :smtp_password,
    :smtp_authentication, :smtp_enable_starttls_auto
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Trackable
  include Pictureable

  #---
  after_create :assign_slug
  after_create :create_guest_group
  after_create :create_header_and_footer
  after_save :reapply_style,
    if: -> (store) { store.saved_change_to_theme? }

  #---
  # Default group for users if not otherwise specified, guests especially.
  # Optional because stores are created without one during onboarding.
  belongs_to :default_group, class_name: 'Group', optional: true

  # Home country, used as default shipping and billing country.
  belongs_to :country, foreign_key: :country_code

  # The hostnames assigned to a store form a network of store portals
  # and member stores through domain/subdomain associations.
  has_many :hostnames, dependent: :destroy
  has_many :domain_hostnames, through: :hostnames
  has_many :subdomain_hostnames, through: :hostnames

  has_many :store_portals, -> { distinct.reorder(:name) }, through: :domain_hostnames, source: :store
  has_many :member_stores, -> { distinct.reorder(:name) }, through: :subdomain_hostnames, source: :store

  # All these associations are dependent of the store.
  with_options dependent: :destroy do |store|
    store.has_many :images
    store.has_many :inventories
    store.has_many :inventory_checks
    store.has_many :transfers
    store.has_many :categories
    store.has_many :departments
    store.has_many :products
    store.has_many :properties
    store.has_many :tags
    store.has_many :orders
    store.has_many :order_types
    store.has_many :shipping_methods
    store.has_many :pages
    store.has_many :albums
    store.has_many :promotions
    store.has_many :tax_categories
    store.has_many :groups
    store.has_many :policies
    store.has_many :subscriptions
  end

  has_one :style

  # The header and footer pages for presentation.
  has_one :header, -> { merge(Page.header) }, class_name: 'Page'
  has_one :footer, -> { merge(Page.footer) }, class_name: 'Page'

  # User supplied footer page, if any.
  belongs_to :footer_page, class_name: 'Page', optional: true

  # Pages intended for portals.
  has_many :portal_pages, -> { merge(Page.portal).merge(Page.live) }, class_name: 'Page'

  has_many :inventory_items, through: :inventories
  has_many :shipping_cost_products, through: :shipping_methods

  # Assigned groups determine which users belong to a store.
  has_many :users, through: :groups

  # Customers who have completed orders at this store.
  has_many :customer_orders, -> { merge(Order.complete) }, through: :users
  has_many :customers, through: :customer_orders

  accepts_nested_attributes_for :tax_categories, limit: 1

  scope :portal, -> { where(portal: true) }
  scope :all_except, -> (this) { where.not(id: this) }

  #---
  validates :name, presence: true
  validates :erp_number, numericality: true, allow_blank: true

  #---
  # The minimal set of default settings for a newly created store.
  def self.default_settings
    {
      card_image_type: 'presentational',
      list_image_type: 'presentational'
    }
  end

  def self.locale_options
    @@locale_options ||= [
      ['English', 'en'],
      ['español', 'es'],
      ['Deutsch', 'de'],
      ['suomi', 'fi']
    ]
  end

  def self.theme_options
    @@themes ||= %w{
      birch boutique cardirad cards cottage darkmatter hiustalo material mechanet premium
    }
  end

  # Options for payment gateways found in the PaymentGateway module.
  def self.payment_gateway_options
    Payment.available_gateways.map do |gateway|
      ["PaymentGateway::#{gateway}".constantize.model_name.human, gateway]
    end
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
  def cart_contents_partial
    fancy_cart? ? 'store/fancy_cart_contents' : 'store/cart_contents'
  end

  def stylesheet_source
    style.present? && style.stylesheet.present? && style.stylesheet.url || "themes/#{theme}"
  end

  # Finds a subdomain hostname belonging to the given store portal.
  def hostname_at(portal)
    hostnames.joins(domain_hostname: :store)
      .find_by(domain_hostnames_hostnames: {store_id: portal})
  end

  # Returns the first hostname for mailers and such with no request context.
  def primary_host
    hostnames.first
  end

  # Only one subscription is active at any time.
  def active_subscription
    subscriptions.active.first
  end

  def eligible_for_trial_subscription?
    subscriptions.none?
  end

  # Let's assume the first inventory is the default one.
  # May be nil if the store doesn't keep stock.
  def default_inventory
    inventories.first
  end

  # Returns the first category. See Page#path.
  def first_category
    categories.live.root
  end

  def available_categories
    categories.live.order(:lft)
  end

  # Properties flagged searchable.
  def searchable_properties
    properties.merge(Property.searchable).merge(Property.sorted)
  end

  # Mapping of properties by external name
  def property_map
    properties.reject { |p| p.external_name.blank? }
      .map { |p| [p.external_name.to_sym, p] }
      .to_h
  end

  def tag_options
    tags.map { |t| [t.name, t.id, data: {appearance: t.appearance}.to_json] }
  end

  def group_options
    groups.map { |g| [g.name, g.id, data: {appearance: g.appearance}.to_json] }
  end

  def shipping_method_options
    shipping_methods.map { |s| [s.name, s.id] }
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
  %w[main_nav_lookup detach_menu masonry fancy_cart cart_promotion favorites category_order inline_iframes admit_guests custom_smtp_settings disable_mail disable_shipment_transfers b2b_sales global_sales smtp_enable_starttls_auto].each do |method|
    alias_method "#{method}?", method
    define_method("#{method}=") do |value|
      super(['1', 1, true].include?(value))
    end
  end

  def correspondents
    users.with_role(:correspondence, self)
  end

  # Returns the stored smtp settings as a hash suitable
  # for Action Mailer smtp delivery method options.
  def smtp_delivery_method_options
    {
      address: smtp_address,
      port: smtp_port.to_i,
      user_name: smtp_user_name,
      password: smtp_password,
      authentication: smtp_authentication.to_sym,
      enable_starttls_auto: smtp_enable_starttls_auto
    }
  end

  # Finds the quotation boilerplate page.
  def quotation_boilerplate
    pages.find_by(id: quotation_template_id)
  end

  # CSV header conversion table for uploaded products.
  def csv_headers
    {
      csv_product_code => :product_code,
      csv_trade_price => :trade_price,
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
    def reapply_style
      if style.present?
        reload
        Styles::Generator.new(theme, style).compile
      end
    end

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

    def create_guest_group
      update(default_group: groups.create(name: Group.human_attribute_name(:default_name)))
    end

    def create_header_and_footer
      pages.header.create_with(title: "#{name} header").first_or_create
      pages.footer.create_with(title: "#{name} footer").first_or_create
    end
end
