module Borderable
  extend ActiveSupport::Concern

  ATTRIBUTES = [
    :border_color, :border_style, :border_width,
    :border_top_color, :border_top_style, :border_top_width,
    :border_right_color, :border_right_style, :border_right_width,
    :border_bottom_color, :border_bottom_style, :border_bottom_width,
    :border_left_color, :border_left_style, :border_left_width
  ].freeze

  STYLES = %w{solid dotted dashed groove inset}.freeze

  UNITS = {
    border_width: 'px',
    border_top_width: 'px',
    border_right_width: 'px',
    border_bottom_width: 'px',
    border_left_width: 'px'
  }.freeze

  def self.unit(attr)
    UNITS[attr]
  end

  included do
    store :borders, accessors: ATTRIBUTES, coder: JSON

    def self.border_style_options
      STYLES
    end
  end
end
