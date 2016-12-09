#encoding: utf-8

class Hostname < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  # Resource is either a store or a portal this hostname points to.
  belongs_to :resource, polymorphic: true

  #---
  validates :fqdn, presence: true, uniqueness: true

  #---
  def to_s
    fqdn
  end
end
