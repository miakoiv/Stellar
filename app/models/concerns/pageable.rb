#
# Pageable adds a page association to a class, declaring the inverse of
# the page's resource association. An after save callback is supplied to
# automatically disable the page if the resource itself becomes disabled.
# Note that the reverse is not true, the page must be manually enabled.
#
module Pageable
  extend ActiveSupport::Concern

  included do
    has_one :page, as: :resource, dependent: :destroy
    after_save :conditionally_disable_page
  end

  private
    # Disables the associated page if this resource has been deactivated.
    # NOTE: this can't be implemented using ActiveModel::Dirty due to
    # awesome_nested_set incompatibility.
    # See <https://github.com/collectiveidea/awesome_nested_set/issues/276>
    def conditionally_disable_page
      if page.present? && !live?
        page.update(live: false)
      end
      true
    end
end
