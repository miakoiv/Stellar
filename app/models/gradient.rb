class Gradient
  include ActiveModel::Model

  TYPES = [
    ['solid', ''],
    ['linear', 'linear'],
    ['circle', 'circle'],
    ['ellipse', 'ellipse']
  ].freeze

  DIRECTIONS = [
    ['↖', 'top left'],
    ['↑', 'top'],
    ['↗', 'top right'],
    ['←', 'left'],
    ['•', ''],
    ['→', 'right'],
    ['↙', 'bottom left'],
    ['↓', 'bottom'],
    ['↘', 'bottom right']
  ].freeze

  #---
  def self.type_options
    TYPES.map { |t, v| [Gradient.human_attribute_value(:type, t), v] }
  end

  def self.direction_options
    DIRECTIONS
  end
end
