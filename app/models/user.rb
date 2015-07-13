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
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Users are restricted to interacting with only one store.
  belongs_to :store

  has_many :orders

  def self.options
    all.map { |u| [u.email, u.id] }
  end


  # A user's shopping cart is technically an order singleton,
  # the one and only order that's not been ordered yet.
  def shopping_cart
    orders.unordered.first || orders.create(store: store)
  end

  # Superiority over another user is decided on the pecking order
  # of their highest ranked roles.
  def superior_to?(user)
    roles.first.id < user.roles.first.id
  end

  def grantable_role_options
    roles.first.grantable_roles.map { |r| [r.to_s, r.id] }
  end

  def role_names
    roles.map { |r| r.to_s }
  end

  def to_s
    new_record? ? 'New user' : email
  end
end
