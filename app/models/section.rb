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
  # Available text and box layouts, with default
  # initial content segment templates.
  LAYOUTS = {
    'col-12' => {
      group: :text,
      segments: %w{column}
    },
    'col-6-6' => {
      group: :text,
      segments: %w{column column}
    },
    'col-4-4-4' => {
      group: :text,
      segments: %w{column column column}
    },
    'col-8-4' => {
      group: :text,
      segments: %w{column column}
    },
    'col-4-8' => {
      group: :text,
      segments: %w{column column}
    },
  }.freeze

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
    LAYOUTS.keys.map { |l| [Section.human_attribute_value(:layout, l), l] }
  end

  def self.width_options
    WIDTHS.map { |w| [Section.human_attribute_value(:width, w), w] }
  end

  #---
  def fluid?
    width == 'width-spread'
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
      LAYOUTS[layout][:segments].each do |template|
        segments.create(template: template)
      end
    end
end
