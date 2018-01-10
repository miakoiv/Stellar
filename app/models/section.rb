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
  # Preset layouts for column and block outlines.
  PRESETS = [
    [:column, [
      [1, 'twelve'],
      [2, 'six-six'],
      [2, 'eight-four'],
      [2, 'four-eight'],
      [3, 'four-four-four'],
      [3, 'three-six-three'],
      [4, 'three-three-three-three'],
    ]],
    [:block, [
      [1, 'twelve'],
      [2, 'six-six'],
      [2, 'eight-four'],
      [2, 'four-eight'],
      [3, 'four-four-four'],
      [3, 'three-six-three'],
      [4, 'three-three-three-three'],
      [3, 'eight-four-four', 'shape-16-9'],
      [3, 'four-four-eight', 'shape-16-9'],
    ]],
  ].freeze

  # Available content widths defined in layouts.css.
  WIDTHS = %w{
    jumbotron spread col-12 col-10 col-8 col-6
  }.freeze

  # Section shape presets to control block segment aspect ratios.
  SHAPES = [
    ['viewport', 'shape-viewport'],
    ['1:1', 'shape-square'],
    ['4:3', 'shape-4-3'],
    ['16:9', 'shape-16-9'],
    ['2:1', 'shape-two-one'],
    ['21:9', 'shape-21-9'],
    ['3:1', 'shape-three-one'],
    ['4:1', 'shape-four-one'],
  ].freeze

  #---
  # Section outline affects the arrangement of its segments.
  # Column sections are ideal for text and other content that requires
  # gutters. Block sections lack gutters, allowing seamless layouts.
  enum outline: [:block, :column]

  #---
  belongs_to :page, touch: true
  has_many :segments, dependent: :destroy

  default_scope { sorted }

  #---
  validates :page_id, presence: true
  validates :width, inclusion: {in: WIDTHS}

  #---
  def self.preset_menu_options
    PRESETS
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  def self.shape_options
    SHAPES
  end

  #---
  def spread?
    width == 'spread'
  end

  def jumbotron?
    width == 'jumbotron'
  end

  def viewport?
    shape == 'shape-viewport'
  end

  def fixed_or_fluid
    shape.present? ? 'fixed-ratio' : 'fluid-ratio'
  end

  # FIXME: this should be dependent on the outline,
  # but we'll need a dynamically updated selector
  # to pull that off in the UI
  def layout_options
    PRESETS.to_h[:block].map { |l| l[1] }
  end

  def image_options
    {purpose: false}
  end

  def background_image
    cover_image
  end

  def default_segment_template
    block? ? 'picture' : 'column'
  end

  def to_s
    priority + 1
  end
end
