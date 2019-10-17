module Borderable
  extend ActiveSupport::Concern

  ATTRIBUTES = [
    :border_color, :border_style, :border_width,
    :border_top_color, :border_top_style, :border_top_width,
    :border_right_color, :border_right_style, :border_right_width,
    :border_bottom_color, :border_bottom_style, :border_bottom_width,
    :border_left_color, :border_left_style, :border_left_width
  ].freeze

  STYLES = %w{none solid dotted dashed groove inset}.freeze

  included do
    store :borders, accessors: ATTRIBUTES, coder: JSON

    def self.border_style_options
      STYLES
    end

    def inline_border_styles
      styles = []
      build_border(styles, :border)
      build_border(styles, :border_top)
      build_border(styles, :border_right)
      build_border(styles, :border_bottom)
      build_border(styles, :border_left)
      styles
    end

    private

    def build_border(s, attr)
      color = send("#{attr}_color").presence
      style = send("#{attr}_style").presence
      width = send("#{attr}_width").presence
      prop = attr.to_s.dasherize
      if style.present?
        s << ["#{prop}-color", color] if color
        s << ["#{prop}-style", style]
        s << ["#{prop}-width", "#{width}px"] if width
      end
    end
  end
end
