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
  # Available layout names defined in layouts.css, with default
  # initial content segment templates.
  LAYOUTS = {
    'box' => %w{empty},
    'single-col' => %w{column},
    'double-col' => %w{column column},
    'triple-col' => %w{column column column},
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
  after_create :create_segments

  #---
  def self.layout_options
    LAYOUTS.keys.map { |l| [Section.human_attribute_value(:layout, l), l] }
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

  private
    def create_segments
      LAYOUTS[layout].each do |template|
        segments.create(template: template)
      end
    end
end
