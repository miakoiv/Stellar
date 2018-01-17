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
  # Presets as layout, column count tuples.
  PRESETS = [
    ['twelve', 1],
    ['six-six', 2],
    ['eight-four', 2],
    ['four-eight', 2],
    ['four-four-four', 3],
    ['three-six-three', 3],
    ['three-three-three-three', 4],
  ].freeze

  # Available content widths defined in layouts.css.
  WIDTHS = %w{
    jumbotron spread col-12 col-10 col-8 col-6
  }.freeze

  #---
  belongs_to :page, touch: true
  has_many :columns, dependent: :destroy
  has_many :segments, through: :columns

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

  #---
  def spread?
    width == 'spread'
  end

  def jumbotron?
    width == 'jumbotron'
  end

  def gutter
    gutters? ? 'gutters' : 'no-gutters'
  end

  def layout_options
    PRESETS.map { |l| l.first }
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
