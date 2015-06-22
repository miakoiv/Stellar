#encoding: utf-8

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :registerable, :recoverable, :confirmable, :lockable,
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Users are restricted to interacting with only one brand.
  belongs_to :brand


  def self.options
    all.map { |u| [u.email, u.id] }
  end


  # Available order types for the user.
  def order_type_options
    brand.order_types.map { |o| [o.to_s, o.id] }
  end

  def to_s
    new_record? ? 'New user' : email
  end
end
