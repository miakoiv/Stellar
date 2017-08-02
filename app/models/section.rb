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
  # Available column and box layouts.
  LAYOUTS = {
    columns: [
      'col-12', 'col-6-6', 'col-4-4-4', 'col-8-4', 'col-4-8'
    ],
    boxen: [
      'box-12', 'box-6-6', 'box-4-4-4', 'box-8-4', 'box-4-8',
      'box-8-4-4', 'box-4-4-8'
    ],
  }.freeze

  # Initial segment templates for each layout.
  SEGMENTS = {
    'col-12' => %w{column},
    'col-6-6' => %w{column column},
    'col-4-4-4' => %w{column column column},
    'col-8-4' => %w{column column},
    'col-4-8' => %w{column column},
    'box-12' => %w{picture},
    'box-6-6' => %w{picture picture},
    'box-4-4-4' => %w{picture picture picture},
    'box-8-4' => %w{picture picture},
    'box-4-8' => %w{picture picture},
    'box-8-4-4' => %w{picture picture picture},
    'box-4-4-8' => %w{picture picture picture},
  }

  # Available widths defined in layouts.css.
  WIDTHS = %w{
    width-spread width-page width-10 width-8 width-6
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
    LAYOUTS
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  #---
  def spread?
    width == 'width-spread'
  end

  def image_options
    {purpose: false}
  end

  def background_image
    cover_image
  end

  def geometry
    "#{Section.human_attribute_value(:layout, layout)}, #{Section.human_attribute_value(:width, width)}"
  end

  def to_s
    geometry
  end

  private
    def create_segments
      SEGMENTS[layout].each do |template|
        segments.create(template: template)
      end
    end
end
