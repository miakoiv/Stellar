#encoding: utf-8

class User < ActiveRecord::Base

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
    orders.pending.first || orders.create
  end

  def to_s
    new_record? ? 'New user' : email
  end
end
