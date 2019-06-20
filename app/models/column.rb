class Column < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Pictureable
  include Reorderable
  include Stylable

  #---
  ALIGNMENTS = %w{align-top align-middle align-bottom align-fill}.freeze

  #---
  belongs_to :section, touch: true
  has_many :segments, dependent: :destroy

  accepts_nested_attributes_for :pictures
  accepts_nested_attributes_for :segments

  default_scope { sorted }

  #---
  def self.alignment_options
    ALIGNMENTS.map { |a| [Column.human_attribute_value(:alignment, a), a] }
  end

  #---
  def span
    @span ||= "col-xs-%d col-sm-%d" % [span_xs, span_sm]
  end

  # Generates a duplicate with duplicated segments.
  def duplicate
    dup.tap do |c|
      c.section = nil
      segments.each do |segment|
        c.segments << segment.duplicate
      end
    end
  end

  def save_inline_styles_recursively
    save_inline_styles
    segments.each do |segment|
      segment.save_inline_styles
    end
  end

  def background_picture
    cover_picture
  end

  def to_s
    priority + 1
  end
end
