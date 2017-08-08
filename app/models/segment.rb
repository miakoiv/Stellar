#encoding: utf-8

class Segment < ActiveRecord::Base

  store :metadata, accessors: [
    :headline,
    :thumbnail_size,
    :map_location, :map_zoom,
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  #---
  THUMBNAIL_SIZES = %w{icon thumbnail matchbox postcard}

  #---
  enum template: {
    empty: 0,
    column: 1,
    picture: 2,
    gallery: 3,
    map: 4,
    category: 11,
    product: 12,
    promotion: 13,
    raw: 99,
  }

  #---
  belongs_to :section
  belongs_to :resource, polymorphic: true

  default_scope { sorted }

  #---
  def self.template_options
    Segment.templates.keys.map { |t| [Segment.human_attribute_value(:template, t), t] }
  end

  def self.thumbnail_size_options
    THUMBNAIL_SIZES.map { |s| [Segment.human_attribute_value(:thumbnail_size, s), s] }
  end

  #---
  def edit_in_place?
    column?
  end

  def image_options
    {purpose: false}
  end

  def to_partial_path
    "segments/templates/#{template}"
  end
end
