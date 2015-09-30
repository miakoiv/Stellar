module Customizable
  extend ActiveSupport::Concern

  included do
    has_many :customizations, as: :customizable, dependent: :destroy

    # Looks up the first customization (if any) that declares unit pricing.
    def unit_pricing_customization
      customizations.joins(:custom_attribute)
        .where(custom_attributes: {unit_pricing: true}).first
    end
  end
end
