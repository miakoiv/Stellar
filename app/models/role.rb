#encoding: utf-8

class Role < ActiveRecord::Base

  scopify

  #---
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  default_scope { order(:id) }

  #---
  validates :resource_type,
    inclusion: {in: Rolify.resource_types},
    allow_nil: true

  #---
  def self.guest
    find_by(name: 'guest')
  end

  #---
  def to_s
    name.humanize
  end

end
