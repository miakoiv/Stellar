#encoding: utf-8

class Hostname < ActiveRecord::Base

  RESTRICTED_FQDNS = [
    ENV['STELLAR_DOMAIN'],
    ENV['STELLAR_HOST']
  ].freeze

  resourcify
  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  belongs_to :store

  # Parent hostname provides domain/subdomains associations.
  belongs_to :domain_hostname, class_name: 'Hostname', foreign_key: :parent_hostname_id
  has_many :subdomain_hostnames, class_name: 'Hostname', foreign_key: :parent_hostname_id


  default_scope { sorted }

  # Hostnames assigned to store portals are semantically domains.
  scope :domain, -> { joins(:store).merge(Store.portal) }
  scope :subdomain, -> { where.not(domain_hostname: nil) }

  validates :fqdn, presence: true, uniqueness: true, exclusion: {in: RESTRICTED_FQDNS}

  #---
  # The store specified by domain hostname, if any.
  def store_portal
    return nil if domain_hostname.nil?
    domain_hostname.store
  end

  def to_url
    "//#{fqdn}"
  end

  def to_s
    fqdn
  end
end
