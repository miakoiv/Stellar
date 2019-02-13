module StripeGateway
  class SubscriptionService

    include ActiveModel::Model

    attr_accessor :store, :user, :stripe_plan_id, :stripe_source_id

    # Creates and returns the actual Subscription object after creating
    # the associated subscription record on Stripe.
    def subscribe!
      Subscription.transaction do
        subscription = create_stripe_subscription!
        store.subscriptions.create!(
          customer: user,
          stripe_plan_id: stripe_plan_id,
          stripe_id: subscription.id,
          first_date: Date.today,
          status: :active
        )
      end
    end

    private
      # Creates the subscription on Stripe with the specified plan,
      # creating the associated customer on the fly.
      def create_stripe_subscription!
        Stripe::Subscription.create(
          customer: create_stripe_customer!,
          tax_percent: Price::DEFAULT_TAX_RATE,
          trial_from_plan: store.eligible_for_trial_subscription?,
          items: [
            {plan: stripe_plan_id},
          ],
          metadata: {store: store.name}
        )
      end

      # Creates a Stripe customer for this particular subscription
      # and assigns the source from Stripe Checkout as default.
      def create_stripe_customer!
        Stripe::Customer.create(
          email: user.email,
          description: store.name,
          source: stripe_source_id
        )
      end
  end
end
