#encoding: utf-8

class Role < ActiveRecord::Base

  scopify

  #---
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true
  has_many :available_order_types, class_name: 'OrderType', foreign_key: :source_role_id, inverse_of: :source_role
  has_many :managed_order_types, class_name: 'OrderType', foreign_key: :destination_role_id, inverse_of: :destination_role

  default_scope { order(:id) }

  #---
  validates :resource_type,
    inclusion: {in: Rolify.resource_types},
    allow_nil: true

  #---
  def self.guest_roles
    where(name: [:see_pricing])
  end

  #---
  def to_s
    name.humanize
  end

end
