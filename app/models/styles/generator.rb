#encoding: utf-8
#
# Style::Generator compiles store stylesheets on demand from the SCSS
# of the theme file prepended by the style variables.
#
# Adapted from <https://github.com/DiatomEnterprises/custom-css-for-user>
#
module Styles
  class Generator

    attr_reader :theme, :style, :filename, :scss_file, :env

    def initialize(theme, style)
      @theme = theme
      @style = style
      @filename = "#{theme}-#{style}"
      @scss_file = File.new(scss_file_path, 'w')
      @env = ::Sprockets::Railtie.build_environment(Rails.application)
    end

    def compile
      create_scss
      begin
        scss_file.write generate_css
        scss_file.flush
        style.update(stylesheet: scss_file)
      ensure
        scss_file.close
        File.delete(scss_file)
      end
    end

    private
      # Store theme file from app assets.
      def theme_file
        @theme_file ||= File.join(
          Rails.root, 'app', 'assets', 'stylesheets', 'spry_themes',
          "#{theme}.scss"
        )
      end

      def style_header
        style.to_scss
      end

      def scss_source
        theme_body = ERB.new(File.read(theme_file)).result(binding)
        style_header + theme_body
      end

      def scss_tmpfile_path
        @tmp_path ||= File.join(
          Rails.root, 'tmp', 'cache', 'assets'
        )
        FileUtils.mkdir_p(@tmp_path) unless File.exists?(@tmp_path)
        @tmp_path
      end

      def scss_file_path
        @scss_file_path ||= File.join(scss_tmpfile_path, "#{filename}.scss")
      end

      def create_scss
        File.open(scss_file_path, 'w') { |f| f.write(scss_source) }
      end

      def generate_css
        SassC::Engine.new(asset_source, {
          syntax: :scss,
          cache: false,
          read_cache: false,
          style: :compressed
        }).render
      end

      def asset_source
        if env.find_asset(filename)
          env.find_asset(filename).source
        else
          uri = Sprockets::URIUtils.build_asset_uri(scss_file.path, type: 'text/css')
          asset = Sprockets::UnloadedAsset.new(uri, env)
          env.load(asset.uri).source
        end
      end
  end
end
