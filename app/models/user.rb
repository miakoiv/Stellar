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

  scope :by_role, -> (role_name) { joins(:roles).where(roles: {name: role_name}) }
  scope :non_guests, -> { includes(:roles).where.not(roles: {name: 'guest'}) }

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
  # A user's shopping cart is technically an order singleton in the scope of
  # current store, the one and only order that's not been ordered yet.
  def shopping_cart(store)
    orders.by_store(store).unordered.first ||
      orders.create(
        store: store,
        order_type: store.default_order_type,
        customer_name: is_guest? ? nil : name,
        customer_email: is_guest? ? nil : email
      )
  end

  # Roles that a user manager may grant to other users. The superuser
  # may promote others to user managers and superusers.
  def grantable_role_options
    roles = [:customer, :see_pricing, :see_stock, :manager, :contact_person, :dashboard_access, :attribute_editor, :category_editor, :order_editor, :page_editor, :product_editor, :promotion_editor]
    roles += [:user_manager, :superuser] if is_superuser?
    Role.where(name: roles).map { |r| [r.to_s, r.id] }
  end

  def role_names
    roles.map { |r| r.to_s }
  end

  def to_s
    "#{name} <#{email}>"
  end

  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
