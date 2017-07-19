#encoding: utf-8
#
# Sections are page subdivisions defining the layout of its content blocks.
# The blocks contain the actual content and have optional associations to
# external resources like images, products, promotions, etc.
#
# The layout for a section is selected from presets that specify how many
# blocks of what size are created inside.
#
class Section < ActiveRecord::Base

  include Imageable
  include Reorderable

  #---
  # Available layouts defined as CSS classes found in layouts.css.
  LAYOUTS = %w{
    single-col double-col triple-col
  }.freeze

  # Available widths with Bootstrap grid CSS classes. Nil width denotes
  # full viewport width, using a fluid container.
  WIDTH_CLASSES = {
    12 => %w{col-xs-12},
    10 => %w{col-xs-12
             col-sm-10 col-sm-offset-1},
     8 => %w{col-xs-10 col-xs-offset-1
             col-sm-8 col-sm-offset-2},
     6 => %w{col-xs-10 col-xs-offset-1
             col-sm-8 col-sm-offset-2
             col-md-6 col-md-offset-3},
  }.freeze

  #---
  belongs_to :page
  has_many :content_blocks, dependent: :destroy

  default_scope { sorted }

  #---
  validates :page_id, presence: true
  validates :width, inclusion: {in: WIDTH_CLASSES.keys}, allow_nil: true
  validates :height, numericality: {only_integer: true}, allow_nil: true

  #---
  def width_classes
    width && WIDTH_CLASSES[width]
  end

  def to_style
    [].tap do |styles|
      height.present? && styles << "height: #{height}em;"
      cover_image.present? && styles << "background-image: url(#{cover_image.url(:lightbox)}); background-size: cover; background-repeat: no-repeat;"
    end.join ' '
  end
end
