#encoding: utf-8

module PaymentGateway
  class StripeSubscription

    include ActiveModel::Model

    attr_accessor :store, :user, :plan, :token

    def subscribe
      true
    end
  end
end
