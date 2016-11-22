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
  validates :user_id, presence: true
  validates :product_id, presence: true

  #---
  after_touch :update_amount_and_value

  #---
  # Creates customer assets and their asset entries from the given order.
  def self.create_from(order)
    store, user = order.store, order.user
    transaction do
      order.order_items.each do |item|
        asset = store.customer_assets.find_or_create_by!(
          user: order.user,
          product: item.product
        )
        asset.asset_entries.create!(
          recorded_at: order.concluded_at,
          source: order,
          amount: item.amount,
          value_cents: item.price_cents || 0
        )
      end
    end
  end

  #---
  def to_s
    "#{product} – #{user}"
  end

  private
    def update_amount_and_value
      entries = asset_entries(true)
      update(
        amount: entries.sum(:amount),
        value: entries.map(&:total_value).sum
      )
    end
end
