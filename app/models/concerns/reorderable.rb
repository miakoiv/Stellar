module Reorderable
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:priority) }
  end
end
