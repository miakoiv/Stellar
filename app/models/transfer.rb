#encoding: utf-8

class Transfer < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  belongs_to :source, class_name: 'Inventory'
  belongs_to :destination, class_name: 'Inventory'

  has_many :transfer_items, dependent: :destroy

  default_scope { order(created_at: :desc) }

  scope :complete, -> { where.not(completed_at: nil) }

  #---
  validates :destination_id, exclusion: {
    in: -> (transfer) { [transfer.source_id] },
    message: :same_as_source
  }

  #---
  def complete?
    completed_at.present?
  end

  def incomplete?
    !complete?
  end

  # Completes the transfer by creating inventory entries corresponding to
  # the changes made to the source and destination inventories by the
  # transfer items.
  def complete!
    now = Time.current
    ActiveRecord::Base.transaction do
      transfer_items.each do |item|
        source.present? && source.destock!(item, now, self)
        destination.present? && destination.restock!(item, now, self)
      end
      update completed_at: now
    end
  end

  def appearance
    incomplete? && 'warning text-warning'
  end

  def icon
    incomplete? && 'cog'
  end

  def to_s
    note
  end
end
