#encoding: utf-8

class User < ActiveRecord::Base

  # Adds `creatable_by?(user)`, etc.
  include Authority::UserAbilities
  include Authority::Abilities
  resourcify
  rolify

  monetize :price_for_cents, disable_validation: true

  # Include default devise modules. Others available are:
  # :registerable, :recoverable, :confirmable, :lockable,
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    request_keys: [:host]

  enum level: {guest: -1, customer: 0, reseller: 1, manufacturer: 2, vendor: 3}

  MANAGED_LEVELS = {
    'guest' => [],
    'customer' => ['customer'],
    'reseller' => ['customer', 'reseller'],
    'manufacturer' => ['customer', 'reseller', 'manufacturer', 'vendor'],
    'vendor' => []
  }.freeze

  LEVEL_LABELS = {
    'guest' => 'default',
    'customer' => 'success',
    'reseller' => 'info',
    'manufacturer' => 'warning',
    'vendor' => 'danger'
  }.freeze

  #---
  # FIXME: Remove this association only after migrating to a state
  # where users don't require a store association anymore.
  belongs_to :store

  # Users may belong to any number of groups to be part of stores.
  has_and_belongs_to_many :groups

  # User may optionally have pricing groups in various stores.
  has_and_belongs_to_many :pricing_groups

  # User may have a set of categories she's restricted to for shopping.
  has_and_belongs_to_many :categories

  # Users (customers) collect assets by ordering products.
  has_many :customer_assets, dependent: :destroy

  has_many :orders, dependent: :destroy

  # Preset shipping and billing addresses have country associations.
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code
  belongs_to :billing_country, class_name: 'Country', foreign_key: :billing_country_code

  default_scope { order(level: :desc, name: :asc) }

  scope :non_guest, -> { where.not(level: levels[:guest]) }

  scope :with_assets, -> { joins(:customer_assets).distinct }

  #---
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {scope: :store}
  validates :phone, presence: true
  validates :password, presence: true, if: :password_required?
  validates :password, confirmation: true

  #---
  # Override Devise hook to find users in the scope of a store, by matching
  # against their host or subdomain attributes.
  def self.find_for_authentication(warden_conditions)
    joins(store: :hostnames)
      .where(email: warden_conditions[:email])
      .where(hostnames: {fqdn: warden_conditions[:host]})
      .first
  end

  #---
  # A user's shopping cart is technically an order singleton,
  # the one and only incomplete order at given store.
  def shopping_cart(store)
    orders.at(store).incomplete.first ||
      orders.at(store).create(
        customer_name: guest? ? nil : name,
        customer_email: guest? ? nil : email,
        customer_phone: guest? ? nil : phone
      )
  end

  # Looks up the relevant price for given product depending on user level.
  def price_for_cents(product, pricing_group)
    return product.cost_price_cents if manufacturer?
    return product.trade_price_cents if reseller?
    product.price_cents(pricing_group)
  end

  # Manufacturer and reseller users always deal with prices sans tax.
  def price_includes_tax?(product)
    return false if manufacturer? || reseller?
    product.tax_category.included_in_retail?
  end

  # Constructs a label for given product, depending on its active promotions.
  def label_for(product)
    return human_attribute_value(:level) if manufacturer? || reseller?
    promoted_item = product.best_promoted_item
    if promoted_item.present?
      return promoted_item.description
    end
    nil
  end

  # Order types seen in the user's set of completed orders.
  def existing_order_types(store)
    orders.at(store).complete.map(&:order_type).uniq
  end

  # Available outgoing order types. These are what the user has available
  # when going through checkout.
  def outgoing_order_types(store)
    store.order_types.outgoing_for(self)
  end

  # Available incoming order types.
  def incoming_order_types(store)
    store.order_types.incoming_for(self)
  end

  # Both of the above
  def available_order_types(store)
    store.order_types.available_for(self)
  end

  def self_and_peers(store)
    store.users.where(level: User.levels[level])
  end

  def managed_levels
    User::MANAGED_LEVELS[level]
  end

  def grantable_level_options
    managed_levels.map { |level| [User.human_attribute_value(:level, level), level, data: {appearance: LEVEL_LABELS[level]}.to_json] }
  end

  # Roles that a user manager may grant to other users. The superuser
  # may promote others to superusers.
  def grantable_roles
    roles = Role.available_roles
    has_cached_role?(:superuser) ? roles : roles - ['superuser']
  end

  # Categories available to this user when creating and editing products.
  def category_options(store)
    available_categories = vendor? ? categories : store.categories
    available_categories.order(:lft).map { |c| [c.to_option, c.id] }
  end

  # Finds the group this user has at the given store.
  def group(store)
    groups.at(store).first
  end

  # Finds the assigned pricing group at store, if any.
  def pricing_group(store)
    pricing_groups.find_by(store: store)
  end

  # Reseller users are able to select a pricing group to use for retail.
  def can_select_pricing_group?
    reseller?
  end

  def appearance
    LEVEL_LABELS[level]
  end

  def to_s
    "#{name} <#{email}>"
  end

  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
