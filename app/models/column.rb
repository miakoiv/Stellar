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

  default_scope { sorted }

  #---
  def self.alignment_options
    ALIGNMENTS.map { |a| [Column.human_attribute_value(:alignment, a), a] }
  end

  #---
  # Generates a duplicate with duplicated segments.
  def duplicate
    dup.tap do |c|
      c.section = nil
      segments.each do |segment|
        c.segments << segment.duplicate
      end
    end
  end

  def background_picture
    cover_picture
  end

  def to_s
    priority + 1
  end
end
