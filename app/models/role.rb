#encoding: utf-8

class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  default_scope { order(:id) }

  validates :resource_type,
    inclusion: {in: Rolify.resource_types},
    allow_nil: true

  scopify

  # Users permitted to create new users may grant them
  # roles that come later in the pecking order.
  def grantable_roles
    Role.where('id > ?', id)
  end

  def to_s
    name.humanize
  end

end
