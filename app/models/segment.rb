#encoding: utf-8

class Segment < ActiveRecord::Base

  store :metadata, accessors: [
    :header,          # headline for category, department segments, etc.
    :subhead,         # subhead to the headline
    :url,             # url to external resource, such as video
    :min_height,      # min height for maps and empty segments
    :grid_columns,    # column count for grid views like galleries
    :masonry,         # flag to apply masonry to the content grid
    :image_sizing,    # image sizing options, one of original, contain, cover
    :max_items,       # number of items to show in category, department segments
    :product_scope,   # product sorting scope in category, department segments
    :show_more,       # flag to include a show more link when max items exceeded
    :map_location,    # location for centering google map segments
    :map_zoom,        # zoom factor of google map segments
    :inverse,         # flag to invert colors in navigation menu segments
    :jumbotron,       # flag to apply the jumbotron class to segment contents
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Documentable
  include Imageable
  include Reorderable

  #---
  ALIGNMENTS = %w{align-top align-middle align-bottom}.freeze

  SHAPES = [
    ['1:1', 'shape-square'],
    ['4:3', 'shape-4-3'],
    ['16:9', 'shape-16-9'],
    ['2:1', 'shape-two-one'],
    ['21:9', 'shape-21-9'],
    ['3:1', 'shape-three-one'],
    ['4:1', 'shape-four-one'],
  ].freeze

  GRID_COLUMNS = %w{1 2 3 4 6 12}.freeze

  IMAGE_SIZES = %w{sizing-original sizing-contain sizing-cover}.freeze

  INSETS = %w{inset-none inset-half inset-full}.freeze

  #---
  enum template: {
    empty: 0,
    text: 1,
    picture: 2,
    gallery: 3,
    map: 4,
    video_player: 5,
    documentation: 6,
    category: 11,
    product: 12,
    promotion: 13,
    department: 14,
    category_feature: 21,
    product_feature: 22,
    promotion_feature: 23,
    department_feature: 24,
    navigation_menu: 50,
    raw: 99,
  }

  #---
  belongs_to :column, touch: true
  belongs_to :resource, polymorphic: true

  before_validation :clear_unwanted_attributes
  after_save :schedule_content_update, if: -> (segment) { segment.body_changed? }

  default_scope {
    joins(:column)
    .order('columns.priority, segments.priority')
  }
  scope :with_content, -> { where(template: [1, 99]) }


  #---
  def self.template_options
    Segment.templates.keys.map { |t| [Segment.human_attribute_value(:template, t), t] }
  end

  def self.shape_options
    SHAPES
  end

  def self.alignment_options
    ALIGNMENTS.map { |a| [Segment.human_attribute_value(:alignment, a), a] }
  end

  def self.grid_columns_options
    GRID_COLUMNS
  end

  def self.image_sizing_options
    IMAGE_SIZES.map { |s| [Segment.human_attribute_value(:image_sizing, s), s] }
  end

  def self.inset_options
    INSETS.map { |i| [Segment.human_attribute_value(:inset, i), i] }
  end

  #---
  def has_content?
    text? || raw?
  end

  def has_min_height?
    empty? || map?
  end

  def edit_in_place?
    text?
  end

  def fixed_ratio?
    shape.present?
  end

  def grid_columns
    super.presence || '3'
  end

  def image_options
    {purpose: []}
  end

  # Defines accessors to boolean settings not generated by Rails.
  %w[inverse jumbotron masonry show_more].each do |method|
    alias_method "#{method}?", method
    define_method("#{method}=") do |value|
      super(['1', 1, true].include?(value))
    end
  end

  def to_s
    human_attribute_value(:template).capitalize
  end

  def to_partial_path
    "segments/templates/#{template}"
  end

  private
    def clear_unwanted_attributes
      self.min_height = nil unless has_min_height?
    end

    def schedule_content_update
      ContentGenerationJob.perform_later(self)
      true
    end
end
