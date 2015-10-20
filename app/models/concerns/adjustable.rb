module Adjustable
  extend ActiveSupport::Concern

  included do
    has_many :adjustments, as: :adjustable, dependent: :destroy
  end
end
