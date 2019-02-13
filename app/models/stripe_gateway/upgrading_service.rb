module StripeGateway
  class UpgradingService

    attr_reader :subscription

    def initialize(subscription)
      @subscription = subscription
    end

    def upgrade!(plan_id)
      Subscription.transaction do
        upgrade_subscription!(plan_id)
        subscription.update!(
          stripe_plan_id: plan_id
        )
      end
    end

    private
      def stripe_subscription
        @stripe_subcription ||= Stripe::Subscription.retrieve(subscription.stripe_id)
      end

      def upgrade_subscription!(plan_id)
        stripe_subscription.cancel_at_period_end = false
        stripe_subscription.items = [{
          id: stripe_subscription.items.data[0].id,
          plan: plan_id
        }]
        stripe_subscription.save
      end
  end
end
