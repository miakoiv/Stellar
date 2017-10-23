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

  #---
  # FIXME: Remove this association only after migrating to a state
  # where users don't require a store association anymore.
  belongs_to :store

  # Users may belong to any number of groups to be part of stores.
  has_and_belongs_to_many :groups

  # Users (customers) collect assets by ordering products.
  has_many :customer_assets, dependent: :destroy

  has_many :orders, dependent: :destroy

  # Order types from outgoing orders. See #existing_order_types below.
  has_many :order_types, -> { joins(:source) }, through: :orders

  # Preset shipping and billing addresses have country associations.
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code
  belongs_to :billing_country, class_name: 'Country', foreign_key: :billing_country_code

  default_scope { order(:name) }

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
        customer_name: guest?(store) ? nil : name,
        customer_email: guest?(store) ? nil : email,
        customer_phone: guest?(store) ? nil : phone
      )
  end

  # Looks up the relevant price for given product depending on user level.
  def price_for_cents(product, pricing_group)
    return product.cost_price_cents if manufacturer?
    return product.trade_price_cents if reseller?
    product.price_cents(pricing_group)
  end

  # FIXME: tax inclusion should not be user specific
  def price_includes_tax?(product)
    product.tax_category.included_in_retail?
  end

  # Order types seen in the user's set of completed orders.
  def existing_order_types(store)
    order_types.merge(Order.complete).where(orders: {store: store}).uniq
  end

  def self_and_peers(store)
    store.users.where(level: User.levels[level])
  end

  # Roles that a user manager may grant to other users. The superuser
  # may promote others to superusers.
  def grantable_roles
    roles = Role.available_roles
    has_cached_role?(:superuser) ? roles : roles - ['superuser']
  end

  # Finds the group this user belongs to at the given store.
  def group(store)
    groups.find_by(store: store)
  end

  def guest?(store)
    group(store) == store.default_group
  end

  def to_s
    "#{name} <#{email}>"
  end

  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
