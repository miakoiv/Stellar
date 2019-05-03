#
# Stylable adds support for inline styling stored in a serialized
# attribute, keyed by feature such as backgroundColor or minHeight.
# Provides #style to fetch previously stored CSS rules ready for inlining,
# and #save_inline_styles that silently updates and saves the attribute.
# Stylable records are assigned a before_save callback to update the
# inlined styles through a Styles::Inline object that employs
# Autoprefixer to add any syntax variants required by different browsers.
#
module Stylable
  extend ActiveSupport::Concern

  included do
    store :inline_styles, coder: JSON

    before_save :update_inline_styles
  end

  def style(*features)
    features.map { |f| inline_styles[f] }.join ' '
  end

  def save_inline_styles
    update_inline_styles
    update_columns(inline_styles: inline_styles)
  end

  private
    def update_inline_styles
      Styles::Inline.new(self).write_inline_styles
    end
end
