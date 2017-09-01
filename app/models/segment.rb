#encoding: utf-8

class Segment < ActiveRecord::Base

  store :metadata, accessors: [
    :headline,
    :grid_columns, :max_items, :show_more, :product_scope,
    :map_location, :map_zoom,
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  #---
  ALIGNMENTS = %w{align-top align-middle align-bottom}.freeze

  GRID_COLUMNS = %w{1 2 3 4 6 12}

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

  def self.alignment_options
    ALIGNMENTS.map { |a| [Segment.human_attribute_value(:alignment, a), a] }
  end

  def self.grid_columns_options
    GRID_COLUMNS
  end

  #---
  def show_more?
    ['1', 1, true].include?(show_more)
  end

  def edit_in_place?
    column?
  end

  def grid_columns
    super.presence || '3'
  end

  def image_options
    {purpose: false}
  end

  def to_partial_path
    "segments/templates/#{template}"
  end
end
