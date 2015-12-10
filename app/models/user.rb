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
  devise :database_authenticatable, :rememberable, :trackable,
    request_keys: [:host]

  #---
  # Users are restricted to interacting with only one store.
  belongs_to :store

  has_many :orders

  # Order types the user has available when going through checkout.
  has_many :available_order_types, -> (user) { joins(inventory: :stores).where('stores.id = ?', user.store) }, through: :roles

  # Order types the user may browse and process as an administrator.
  has_many :managed_order_types, -> (user) { joins(inventory: :stores).where('stores.id = ?', user.store) }, through: :roles

  scope :by_role, -> (role_name) { joins(:roles).where(roles: {name: role_name}) }
  scope :non_guests, -> { where(guest: false) }

  #---
  validates :name, presence: true
  validates :email, presence: true
  validates :password, presence: true, if: :password_required?
  validates :password, confirmation: true

  #---
  # Override Devise hook to find users in the scope of a store.
  def self.find_for_authentication(warden_conditions)
    joins(:store).where(email: warden_conditions[:email], stores: {host: warden_conditions[:host]}).first
  end

  #---
  # A user's shopping cart is technically an order singleton,
  # the one and only incomplete order.
  def shopping_cart
    orders.incomplete.first ||
      orders.create(
        store: store,
        order_type: available_order_types.find_by(has_shipping: true),
        customer_name: guest? ? nil : name,
        customer_email: guest? ? nil : email
      )
  end

  # Roles that a user manager may grant to other users. The superuser
  # may promote others to user managers and superusers.
  def grantable_role_options
    roles = if has_cached_role?(:superuser)
      Role.all
    else
      Role.where.not(name: [:user_manager, :superuser])
    end
    roles.map { |r| [r.to_s, r.id] }
  end

  def to_s
    "#{name} <#{email}>"
  end

  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
