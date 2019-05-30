module Videoable
  extend ActiveSupport::Concern

  included do
    has_many :videos, as: :videoable, dependent: :destroy
  end
end
