#encoding: utf-8
#
# Sections are page subdivisions defining the layout of its content segments.
# The segments contain the actual content and have optional associations to
# external resources like images, products, promotions, etc.
#
# The layout for a section is selected from presets that specify how many
# contained segments are created.
#
class Section < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  #---
  # Preset column and box layouts.
  PRESETS = {
    column: ['12', '6-6', '4-4-4', '8-4', '4-8', '3-3-3-3'],
    block: ['12', '6-6', '4-4-4', '8-4-4', '4-4-8', '3-3-3-3'],
  }.freeze

  # Segment widths for preset layouts.
  SEGMENTS = {
    '12' => ['col-12 full'],
    '6-6' => ['col-6 full', 'col-6 full'],
    '4-4-4' => ['col-4 full', 'col-4 full', 'col-4 full'],
    '8-4' => ['col-8 full', 'col-4 full'],
    '4-8' => ['col-4 full', 'col-8 full'],
    '8-4-4' => ['col-8-left full', 'col-4-right half', 'col-4-right half'],
    '4-4-8' => ['col-8-right full', 'col-4-left half', 'col-4-left half'],
    '3-3-3-3' => ['col-3 full', 'col-3 full', 'col-3 full', 'col-3 full'],
  }.freeze

  # Available widths defined in layouts.css.
  WIDTHS = %w{
    spread col-12 col-10 col-8 col-6
  }.freeze

  ALIGNMENTS = %w{none align-top align-middle align-bottom}.freeze

  #---
  # Section layout decides whether to use gutters between segments.
  enum layout: [:block, :column]

  #---
  belongs_to :page
  has_many :segments, dependent: :destroy

  default_scope { sorted }

  #---
  validates :page_id, presence: true
  validates :width, inclusion: {in: WIDTHS}
  validates :height, numericality: {greater_than: 0, allow_nil: true}

  #---
  def self.preset_options
    PRESETS
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  def self.alignment_options
    ALIGNMENTS.map { |a| [Section.human_attribute_value(:alignment, a), a] }
  end

  #---
  def spread?
    width == 'spread'
  end

  def image_options
    {purpose: false}
  end

  def background_image
    cover_image
  end

  def to_s
    priority + 1
  end
end
