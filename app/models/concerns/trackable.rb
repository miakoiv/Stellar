#
# Including Trackable in a model establishes a has_many association
# with activities where the record was the context of the activity.
#
module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :context
  end
end
