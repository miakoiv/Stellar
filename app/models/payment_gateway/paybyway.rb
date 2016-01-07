#encoding: utf-8

module PaymentGateway

  class Paybyway
    include ActiveModel::Model

    attr_accessor :order, :charge

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @api_key = order.store.pbw_api_key
      @private_key = order.store.pbw_private_key
      @version = 'w3'

      self.charge = {
        amount: order.grand_total.cents,
        order_number: Time.now.to_f,
        currency: order.grand_total.currency_as_string,
        card_token: nil,
        email: order.customer_email,
        customer: {

        },
        payment_method: {

        }
      }
    end

    def to_partial_path
      'payment_gateway/paybyway'
    end
  end
end
