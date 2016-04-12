#encoding: utf-8
#
# CustomerAssets keep track of a user's tangible property in the form
# of products, by quantity (amount) and total value. Once created, an
# asset is never edited directly, but modified when an associated asset
# entry is created.
#
class CustomerAsset < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  monetize :value_cents

  #---
  belongs_to :store
  belongs_to :user
  belongs_to :product

  has_many :asset_entries, dependent: :destroy

  #---
  def to_s
    "#{product} – #{user}"
  end
end
