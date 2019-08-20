#
# Sections are page subdivisions defining the layout of its content segments.
# The segments contain the actual content and have optional associations to
# external resources like images, products, promotions, etc.
#
# The layout for a section is selected from presets that specify how many
# contained segments are created.
#
class Section < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Pictureable
  include Reorderable
  include Stylable
  include Videoable

  #---
  # Section layout presets defined as tuples of
  # column spans for xs and sm viewports.
  SPANS = {
    'twelve' => {xs: [12], sm: [12]},
    'eight-four' => {xs: [12, 12], sm: [8, 4]},
    'four-eight' => {xs: [12, 12], sm: [4, 8]},
    'four-four-four' => {xs: [12]*3, sm: [4]*3},
    'two-two-two-two-two-two' => {xs: [6]*6, sm: [2]*6},
    'six-six' => {xs: [12, 12], sm: [6, 6]},
    'nine-three' => {xs: [12, 12], sm: [9, 3]},
    'three-nine' => {xs: [12, 12], sm: [3, 9]},
    'six-three-three' => {xs: [12, 6, 6], sm: [6, 3, 3]},
    'three-six-three' => {xs: [6, 12, 6], sm: [3, 6, 3]},
    'three-three-six' => {xs: [6, 6, 12], sm: [3, 3, 6]},
    'three-three-three-three' => {xs: [6]*4, sm: [3]*4},
  }.freeze

  # Available content widths defined in layouts.css.
  WIDTHS = %w{
    spread col-12 col-10 col-8 col-6
  }.freeze

  GRADIENT_TYPES = %w{linear circle ellipse}.freeze

  GRADIENT_DIRECTIONS = [
    'top left', 'top', 'top right',
    'left', 'right',
    'bottom left', 'bottom', 'bottom right'
  ].freeze

  #---
  belongs_to :page, touch: true
  has_many :columns, dependent: :destroy
  has_many :segments, -> { reorder('columns.priority, segments.priority') }, through: :columns

  accepts_nested_attributes_for :pictures
  accepts_nested_attributes_for :columns

  default_scope { sorted }
  scope :named, -> { where.not(name: nil) }

  #---
  validates :name, uniqueness: {scope: :page, allow_blank: true}
  validates :width, inclusion: {in: WIDTHS}

  #---
  def self.preset_menu_options
    SPANS
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  def self.gradient_type_options
    GRADIENT_TYPES.map { |g| [Section.human_attribute_value(:gradient_type, g), g] }
  end

  def self.gradient_direction_options
    GRADIENT_DIRECTIONS.map { |g| [Section.human_attribute_value(:gradient_direction, g), g] }
  end

  #---
  def spread?
    width == 'spread'
  end

  def remaining_span
    12 - columns.sum(:span_sm)
  end

  # Returns attributes for creating a new column that fills
  # the remaining space in this section.
  def new_column_attributes
    {
      span_sm: remaining_span,
      priority: columns.count
    }
  end

  def picture_options
    {purpose: ['presentational']}
  end

  def background_picture
    cover_picture
  end

  # Generates a duplicate with duplicated columns.
  def duplicate
    dup.tap do |c|
      c.page = nil
      columns.each do |column|
        c.columns << column.duplicate
      end
      pictures.each do |picture|
        c.pictures << picture.duplicate
      end
    end
  end

  def save_inline_styles_recursively
    save_inline_styles
    columns.each do |column|
      column.save_inline_styles_recursively
    end
  end

  def to_s
    name || priority + 1
  end
end
