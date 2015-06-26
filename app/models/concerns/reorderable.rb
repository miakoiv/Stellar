module Reorderable
  extend ActiveSupport::Concern

  included do
    default_scope { order(:priority) }
  end
end
