#
# Guest cleanup destroys a guest user unless she has completed
# at least one order. This job is queued when a guest user is
# first created.
#
class GuestCleanupJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.destroy unless user.orders.complete.any?
  end
end
