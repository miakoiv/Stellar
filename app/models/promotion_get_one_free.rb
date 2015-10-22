#encoding: utf-8

class PromotionGetOneFree < PromotionHandler

  validates :required_items,
    numericality: {only_integer: true, greater_than: 1},
    on: :update
  validates :discount_percent,
    numericality: {
      only_integer: true,
      greater_than: 0,
      less_than_or_equal_to: 100
    }, on: :update
end
