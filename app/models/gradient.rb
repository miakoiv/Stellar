class Gradient
  include ActiveModel::Model

  TYPES = %w{linear circle ellipse}.freeze

  DIRECTIONS = [
    'top left', 'top', 'top right',
    'left', 'right',
    'bottom left', 'bottom', 'bottom right'
  ].freeze

  #---
  def self.type_options
    TYPES.map { |g| [Gradient.human_attribute_value(:type, g), g] }
  end

  def self.direction_options
    DIRECTIONS.map { |g| [Gradient.human_attribute_value(:direction, g), g] }
  end
end
