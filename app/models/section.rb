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
    column: ['12', '6-6', '4-4-4', '8-4', '4-8'],
    block: ['12', '6-6', '4-4-4', '8-4-4', '4-4-8'],
  }.freeze

  # Segment widths for preset layouts.
  SEGMENTS = {
    '12' => ['col-12 full'],
    '6-6' => ['col-6 full', 'col-6 full'],
    '4-4-4' => ['col-4 full', 'col-4 full', 'col-4 full'],
    '8-4' => ['col-8 full', 'col-4 full'],
    '4-8' => ['col-4 full', 'col-8 full'],
    '8-4-4' => ['col-8 full', 'col-4 half', 'col-4 half'],
    '4-4-8' => ['col-8-push full', 'col-4-pull half', 'col-4-pull half'],
  }.freeze

  # Available widths defined in layouts.css.
  WIDTHS = %w{
    spread col-12 col-10 col-8 col-6
  }.freeze

  ASPECT_RATIOS = {
    '4:1' => 1.0/4.0,
    '3:1' => 1.0/3.0,
    '21:9' => 9.0/21.0,
    '16:9' => 9.0/16.0,
    '3:2' => 2.0/3.0,
    '4:3' => 3.0/4.0,
    '1:1' => 1.0,
    '3:4' => 4.0/3.0,
    '2:3' => 3.0/2.0,
    '1:2' => 2.0
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

  #---
  def self.preset_options
    PRESETS
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  def self.aspect_ratio_options
    ASPECT_RATIOS.keys.map { |a| [Section.human_attribute_value(:aspect_ratio, a)] }
  end

  def self.alignment_options
    ALIGNMENTS.map { |a| [Section.human_attribute_value(:alignment, a), a] }
  end

  #---
  def spread?
    width == 'spread'
  end

  def fixed_ratio?
    aspect_ratio.present?
  end

  def aspect_ratio_percentage
    100 * ASPECT_RATIOS[aspect_ratio]
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
