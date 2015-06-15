#encoding: utf-8

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :registerable, :recoverable, :confirmable, :lockable,
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable


  def self.options
    all.map { |u| [u.email, u.id] }
  end


  def to_s
    new_record? ? 'New user' : email
  end
end
