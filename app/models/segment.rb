#encoding: utf-8

class Segment < ActiveRecord::Base

  store :metadata, accessors: [
    :map_latitude,    # map location
    :map_longitude,   # coordinates
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  #---
  enum template: {
    plain: 0,
    column: 1,
    header: 2,
    picture: 3,
    gallery: 4,
    map: 5,
    category: 11,
    product: 12,
    promotion: 13,
  }

  #---
  belongs_to :section
  belongs_to :resource, polymorphic: true

  default_scope { sorted }

  #---
  def self.template_options
    Segment.templates.keys.map { |t| [Segment.human_attribute_value(:template, t), t] }
  end

  #---
  def to_partial_path
    "segments/templates/#{template}"
  end
end
