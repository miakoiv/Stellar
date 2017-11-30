#encoding: utf-8
#
# Implementation of the Bambora PayForm née Paybyway API, including
# payment token requests, credit card charge requests & verifications,
# and bank e-payments.
# For API docs, see
# <https://payform.bambora.com/docs/web_payments/?page=full-api-reference>

module PaymentGateway

  class PaybywayConnector
    include HTTParty
    base_uri 'https://payform.bambora.com/pbwapi/'
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    def auth_payment(token_request)
      self.class.post('/auth_payment', body: token_request.to_json)
    end

    def check_payment_status(verify_request)
      self.class.post('/check_payment_status', body: verify_request.to_json)
    end

    def charge_url
      "#{self.class.base_uri}/charge"
    end

    def token_url(token)
      "#{self.class.base_uri}/token/#{token}"
    end
  end

  class Paybyway

    include ActiveModel::Model

    attr_accessor :order, :return_url, :notify_url

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @api_key = order.store.pbw_api_key
      @private_key = order.store.pbw_private_key
      @version = 'w3.1'
      @connector = PaybywayConnector.new
    end

    #
    # The methods below create charge requests and return JSON responses.
    #
    def charge_credit_card(params = {})
      request = token_request(payment_method: {
        type: 'card', register_card_token: 0
      })
      response = @connector.auth_payment(request).parsed_response
      {
        result: response['result'],
        token: response['token'],
        amount: request[:amount],
        currency: request[:currency],
        payment_url: @connector.charge_url
      }
    end

    def charge_e_payment(params = {})
      request = token_request(payment_method: {
        type: 'e-payment',
        return_url: return_url,
        notify_url: notify_url,
        lang: 'fi',
        token_valid_until: (Time.current + 6.hours).to_i,
        selected: [params[:selected]]
      })
      response = @connector.auth_payment(request).parsed_response
      {
        payment_url: @connector.token_url(response['token'])
      }
    end

    # Sends a payment status request.
    def verify(token)
      request = verify_request(token)
      response = @connector.check_payment_status(request).parsed_response
      response['result'] == 0
    end

    # Checks the return params from a bank e-payment.
    # Returns the unique order number if successful, nil otherwise.
    def return(params)
      return_code  = params['RETURN_CODE']
      order_number = params['ORDER_NUMBER']
      settled      = params['SETTLED']
      contact_id   = params['CONTACT_ID']
      incident_id  = params['INCIDENT_ID']
      authcode     = params['AUTHCODE']
      return nil unless return_code == '0'
      if return_code.present? && order_number.present? && authcode.present?
        cleartext = [return_code, order_number, settled, contact_id, incident_id].compact.join('|')
        if authcode == sha256(@private_key, cleartext)
          return order_number
        end
      end
      nil
    end

    def to_partial_path
      'payment_gateway/paybyway'
    end

    private

      def token_request(options = {})
        number = SecureRandom.hex(12)
        first, last = order.customer_name.split(/\s+/, 2)
        street, zip, city = order.billing_address_components
        {
          version: @version,
          api_key: @api_key,
          order_number: number,
          amount: order.grand_total_with_tax.cents,
          currency: order.grand_total_with_tax.currency_as_string,
          email: order.customer_email,
          authcode: sha256(@private_key, "#{@api_key}|#{number}"),
          customer: {
            firstname: first,
            lastname: last,
            email: order.customer_email,
            address_street: street,
            address_zip: zip,
            address_city: city
          }
        }.merge(options)
      end

      def verify_request(token)
        {
          version: @version,
          api_key: @api_key,
          token: token,
          authcode: sha256(@private_key, "#{@api_key}|#{token}")
        }
      end

      def sha256(secret, data)
        OpenSSL::HMAC.hexdigest('sha256', secret, data).upcase
      end
  end
end
