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

  enum group: {guest: -1, customer: 0, reseller: 1, manufacturer: 2}

  MANAGED_GROUPS = {
    'guest' => [],
    'customer' => ['customer'],
    'reseller' => ['customer', 'reseller'],
    'manufacturer' => ['customer', 'reseller', 'manufacturer']
  }.freeze

  GROUP_LABELS = {
    'guest' => 'default',
    'customer' => 'success',
    'reseller' => 'info',
    'manufacturer' => 'warning'
  }.freeze

  #---
  # Users are restricted to interacting with only one store.
  belongs_to :store

  has_many :orders, dependent: :destroy

  default_scope { order(group: :desc, name: :asc) }

  scope :by_role, -> (role_name) { joins(:roles).where(roles: {name: role_name}) }
  scope :non_guest, -> { where.not(group: groups[:guest]) }

  #---
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {scope: :store}
  validates :phone, presence: true
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
        customer_name: guest? ? nil : name,
        customer_email: guest? ? nil : email,
        customer_phone: guest? ? nil : phone
      )
  end

  # Order types the user has available when going through checkout.
  def available_order_types
    store.order_types.where(source_group: User.groups[group])
  end

  # Order types the user may browse and process as an administrator.
  def managed_order_types
    store.order_types.where(destination_group: User.groups[group])
  end

  def managed_groups
    User::MANAGED_GROUPS[group]
  end

  def grantable_group_options
    managed_groups.map { |group| [User.human_attribute_value(:group, group), group] }
  end

  # Roles that a user manager may grant to other users. The superuser
  # may promote others to superusers.
  def grantable_role_options
    roles = if has_cached_role?(:superuser)
      Role.all
    else
      Role.where.not(name: [:superuser])
    end
    roles.map { |r| [r.to_s, r.id] }
  end

  # Other users the user may manage.
  def managed_users
    store.users.where(group: managed_groups.map { |group| User.groups[group] })
  end

  def appearance
    GROUP_LABELS[group]
  end

  def to_s
    "#{name} <#{email}>"
  end

  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
