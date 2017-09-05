#encoding: utf-8

class Hostname < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  default_scope { sorted }
  scope :subdomain, -> { where.not(parent_hostname: nil) }

  #---
  # Resource is either a store or a portal this hostname points to.
  belongs_to :resource, polymorphic: true
  scope :portal, -> { where(resource_type: 'Portal') }
  scope :portals_for, -> (store) { where(resource: store.portals) }

  # Parent hostname provides domain/subdomains associations.
  belongs_to :parent_hostname, class_name: 'Hostname'
  has_many :subdomain_hostnames, class_name: 'Hostname', foreign_key: :parent_hostname_id

  #---
  validates :fqdn, presence: true, uniqueness: true

  #---
  def to_url
    "//#{fqdn}"
  end

  def to_s
    fqdn
  end
end
