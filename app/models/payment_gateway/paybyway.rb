#encoding: utf-8

module PaymentGateway

  class PaybywayConnector
    include HTTParty
    base_uri 'https://www.paybyway.com/pbwapi'
    headers 'Content-Type' => 'application/json'
    format :json
    debug_output Rails.logger
  end

  class Paybyway

    include ActiveModel::Model

    attr_accessor :order

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @api_key = order.store.pbw_api_key
      @private_key = order.store.pbw_private_key
      @version = 'w3'
    end

    #
    # The methods below create charge requests and return JSON responses.
    #
    def charge_credit_card
      @token_request ||= token_request
      @token_request[:payment_method] = {type: 'card', register_card_token: 0}
      result = PaybywayConnector.post('/auth_payment', body: @token_request.to_json)
      Rails.logger.info result
      result
    end

    # Call PaymentGateway::Paybyway::validate(token: 'token_string')
    # to check the status of a payment by its token. Returns a hash:
    # {success: boolean, message: string}
    def self.validate(params = {})

    end

    def to_partial_path
      'payment_gateway/paybyway'
    end

    private

      def token_request
        number = SecureRandom.hex(12)
        first, last = order.customer_name.split(/\s+/, 2)
        street, zip, city = order.billing_address_components
        {
          version: @version,
          api_key: @api_key,
          order_number: number,
          amount: order.grand_total.cents,
          currency: order.grand_total.currency_as_string,
          email: "noreply@#{order.store.host}",
          authcode: sha256(@private_key, "#{@api_key}|#{number}"),
          customer: {
            firstname: first,
            lastname: last,
            email: order.customer_email,
            address_street: street,
            address_zip: zip,
            address_city: city
          }
        }
      end

      def sha256(secret, data)
        OpenSSL::HMAC.hexdigest('sha256', secret, data).upcase
      end
  end
end
