#encoding: utf-8
#
# Styles::Inline models a collection of inline CSS rules based on
# an ActiveRecord object that responds to one or more methods that
# define its appearance. Upon initialization, the record is queried
# with styling methods to construct CSS declarations, which are then
# run through Autoprefixer and stored in the record metadata.
#
module Styles
  class Inline

    attr_reader :r

    def initialize(record)
      @r = record
    end

    # Writes Autoprefixed rules into the inline styles attribute.
    def write_inline_styles
      write(:backgroundColor, background_color)
      write(:backgroundImage, background_image, true)
      write(:minHeight, min_height)
      write(:margins, margins)
    end

    private
      # Writes a list of CSS declaration into the inline styles attribute,
      # optionally applying Autoprefixer to the declaration.
      def write(key, declarations, autoprefix = false)
        return false unless declarations.present?
        value = declarations.map { |declaration|
          property, rule = declaration
          property && rule && "#{property}: #{rule};"
        }.compact.join ' '
        r.inline_styles[key] = if autoprefix
          AutoprefixerRails.process(value).css
        else
          value
        end
      end

      def background_color
        if r.respond_to?(:background_color)
          if r.respond_to?(:gradient_type) && r.gradient_type.present?
            [['background-image', background_gradient]]
          else
            [['background-color', r.background_color.presence]]
          end
        end
      end

      def background_image
        if r.respond_to?(:background_picture) && r.background_picture.present?
          url = r.background_picture.image.url(:lightbox, timestamp: false)
          [['background-image', "url(#{url})"]]
        end
      end

      def min_height
        if r.respond_to?(:min_height) && r.min_height.present?
          [['min-height', "#{r.min_height}em"]]
        end
      end

      def margins
        if r.respond_to?(:margin_top)
          [
            ['margin-top', "#{r.margin_top}px"],
            ['margin-bottom', "#{r.margin_bottom}px"]
          ]
        end
      end

      def background_gradient
        to = r.gradient_direction.humanize(capitalize: false)
        at = to.present? ? "at #{to}" : ''
        balance = r.gradient_balance.to_i
        start = balance > 0 ? balance : 0
        stop = balance < 0 ? 100 + balance : 100
        color_stops = "#{r.background_color} #{start}%, #{r.gradient_color} #{stop}%"
        if r.gradient_type == 'linear'
          "linear-gradient(to #{to}, #{color_stops})"
        else
          "radial-gradient(#{r.gradient_type} #{at}, #{color_stops})"
        end
      end
  end
end
