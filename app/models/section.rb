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
  # Available layouts defined as CSS classes found in layouts.css.
  LAYOUTS = %w{
    single-col double-col triple-col
  }.freeze

  # Available widths defined in layouts.css.
  WIDTHS = %w{
    fluid twelve ten eight six
  }.freeze

  #---
  belongs_to :page
  has_many :segments, dependent: :destroy

  default_scope { sorted }

  #---
  validates :page_id, presence: true
  validates :width, inclusion: {in: WIDTHS}
  validates :height, numericality: {only_integer: true}, allow_nil: true

  #---
  def self.layout_options
    LAYOUTS.map { |l| [Section.human_attribute_value(:layout, l), l] }
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  #---
  def fluid?
    width == 'fluid'
  end

  def to_style
    [].tap do |styles|
      height.present? && styles << "height: #{height}em;"
      cover_image.present? && styles << "background-image: url(#{cover_image.url(:lightbox)}); background-size: cover; background-repeat: no-repeat;"
    end.join ' '
  end

  def geometry
    "#{Section.human_attribute_value(:layout, layout)}, #{Section.human_attribute_value(:width, width)}"
  end

  def to_s
    geometry
  end
end
