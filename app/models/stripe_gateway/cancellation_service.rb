#encoding: utf-8
#
# CancellationService takes a Subscription record and
# cancels it on Stripe by setting cancel_at_period_end.
# The subscription status is set to cancelling.

module StripeGateway
  class CancellationService

    attr_reader :subscription

    def initialize(subscription)
      @subscription = subscription
    end

    def cancel!
      Subscription.transaction do
        cancel_subscription!
        subscription.update!(
          status: :cancelling,
          last_date: last_date
        )
      end
    end

    private
      def stripe_subscription
        @stripe_subcription ||= Stripe::Subscription.retrieve(subscription.stripe_id)
      end

      def last_date
        Time.at(stripe_subscription.current_period_end).to_date
      end

      def cancel_subscription!
        stripe_subscription.cancel_at_period_end = true
        stripe_subscription.save
      end
  end
end
