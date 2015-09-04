module Customizable
  extend ActiveSupport::Concern

  included do
    has_many :customizations, as: :customizable, dependent: :destroy
  end
end
