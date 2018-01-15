#encoding: utf-8

class Column < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  #---
  ALIGNMENTS = %w{align-top align-middle align-bottom}.freeze

  #---
  belongs_to :section, touch: true
  has_many :segments, dependent: :destroy

  default_scope { sorted }

  #---
  validates :section_id, presence: true

  #---
  def self.alignment_options
    ALIGNMENTS.map { |a| [Column.human_attribute_value(:align, a), a] }
  end

  #---
  def to_s
    priority + 1
  end
end
