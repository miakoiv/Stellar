module Reorderable
  extend ActiveSupport::Concern
  include OrderQuery

  included do
    order_query :ordered,
      [:priority, :asc],
      [:id, :asc]
  end
end
