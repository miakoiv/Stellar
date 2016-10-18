#encoding: utf-8
#
# AssetEntries record the changes made to a CustomerAsset object during its
# lifetime. Entries are created automatically from order items when an order
# is concluded, and can be created manually to bring customer assets up to date
# with various circumstances.
#
class AssetEntry < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # Values are for each, total value is added to customer asset value.
  monetize :value_cents
  monetize :total_value_cents, disable_validation: true

  #---
  belongs_to :customer_asset, touch: true

  # The source can be any object that's responsible for the existence
  # of this particular entry.
  belongs_to :source, polymorphic: true

  default_scope { order(recorded_at: :desc, created_at: :desc) }

  #---
  validates :recorded_at, presence: true
  validates :amount, numericality: {only_integer: true}

  #---
  def total_value_cents
    amount * value_cents
  end
end
