#encoding: utf-8

class User < ActiveRecord::Base

  # Adds `creatable_by?(user)`, etc.
  include Authority::UserAbilities
  include Authority::Abilities
  resourcify
  rolify

  # Include default devise modules. Others available are:
  # :registerable, :recoverable, :confirmable, :lockable,
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  #---
  # Users may belong to any number of groups to be part of stores.
  has_and_belongs_to_many :groups
  has_many :stores, through: :groups

  # Users (customers) collect assets by ordering products.
  has_many :customer_assets, dependent: :destroy

  has_many :orders, dependent: :destroy
  has_many :customer_orders, class_name: 'Order', foreign_key: :customer_id, inverse_of: :customer

  # Order types from outgoing orders. See #existing_order_types below.
  has_many :order_types, -> { joins(:source) }, through: :orders

  # Preset shipping and billing addresses have country associations.
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code
  belongs_to :billing_country, class_name: 'Country', foreign_key: :billing_country_code

  default_scope { order(:name) }

  scope :with_assets, -> { joins(:customer_assets).distinct }

  #---
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, on: :update
  validates :phone, presence: true, on: :update, if: :approved?
  validates :password, presence: true, if: :password_required?
  validates :password, confirmation: true

  #---
  # A user's shopping cart is the only incomplete order at given store
  # with her as the customer.
  def shopping_cart(store, store_portal, group)
    cart = orders.at(store).for(self).incomplete.first
    return cart unless cart.nil?

    cart = orders.at(store).for(self).build(
      inventory: store.default_inventory,
      store_portal: store_portal,
      includes_tax: group.price_tax_included?
    )
    cart.address_to_customer(group.guest?)
    cart.save!
    cart
  end

  # Order types seen in the user's set of completed orders.
  def existing_order_types(store)
    order_types.merge(Order.complete).where(orders: {store: store}).uniq
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

  # Overrides Devise method to ensure the user is approved.
  def active_for_authentication?
    super && approved?
  end

  def require_password?
    encrypted_password.blank?
  end

  protected
    def password_required?
      persisted? && (
        encrypted_password.nil? ||
        password.present? ||
        password_confirmation.present?
      )
    end
end
