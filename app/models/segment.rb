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
  LOREM_IPSUM = '<p><font color="#cec6ce">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</font></p>'

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
  enum alignment: [:top, :middle, :bottom]


  #---
  belongs_to :section
  belongs_to :resource, polymorphic: true

  default_scope { sorted }

  #---
  before_create :fill_default_content

  #---
  def self.template_options
    Segment.templates.keys.map { |t| [Segment.human_attribute_value(:template, t), t] }
  end

  def self.alignment_options
    Segment.alignments.keys.map { |a| [Segment.human_attribute_value(:alignment, a), a] }
  end

  #---
  def to_partial_path
    "segments/templates/#{template}"
  end

  private
    def fill_default_content
      self.body = LOREM_IPSUM if column?
    end
end
