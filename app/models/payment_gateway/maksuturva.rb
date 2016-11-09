#encoding: utf-8
#
# PaymentGateway::Maksuturva encapsulates the data and logic needed to
# communicate with maksuturva.fi brokering service.
#
module PaymentGateway

  class Maksuturva
    include ActiveModel::Model

    PMT_KEY = '11223344556677889900'

    attr_accessor :order

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
      @options = {
        ok_url: "/orders/#{order.id}/ok",
        error_url: "/cart",
        cancel_url: "/cart"
      }
      @params = [
        [:pmt_action, 'NEW_PAYMENT_EXTENDED'],
        [:pmt_version, '0004'],
        [:pmt_id, order.id],
        [:pmt_orderid, order.number],
        [:pmt_reference, reference(order.id.to_s)],
        [:pmt_duedate, (Date.current + 2.weeks).to_s(:fi)],
        [:pmt_amount, ('%.2f' % order.grand_total_with_tax).tr('.', ',')],
        [:pmt_currency, 'EUR'],
        [:pmt_okreturn, @options[:ok_url]],
        [:pmt_errorreturn, @options[:error_url]],
        [:pmt_cancelreturn, @options[:cancel_url]],
        [:pmt_delayedpayreturn, @options[:cancel_url]],
        [:pmt_escrow, 'N'],
        [:pmt_escrowchangeallowed, 'N'],
        [:pmt_buyername, order.user_name],
        [:pmt_buyeraddress, order.billing_address],
        [:pmt_buyerpostalcode, order.billing_postalcode],
        [:pmt_buyercity, order.billing_city],
        [:pmt_buyercountry, order.billing_country_code],
        [:pmt_deliveryname, order.user_name],
        [:pmt_deliveryaddress, order.shipping_address],
        [:pmt_deliverypostalcode, order.shipping_postalcode],
        [:pmt_deliverycity, order.shipping_city],
        [:pmt_deliverycountry, order.shipping_country_code],
        [:pmt_sellercosts, '0,00'],
      ]
      order.order_items.each_with_index do |item, n|
        @params += [
          ["pmt_row_name#{n+1}", item.product_title],
          ["pmt_row_desc#{n+1}", item.product_title],
          ["pmt_row_quantity#{n+1}", item.amount],
          ["pmt_row_deliverydate#{n+1}", (order.shipping_at.presence || Date.current).to_s(:fi)],
          ["pmt_row_price_net#{n+1}", item.price.to_s.tr('.', ',')],
          ["pmt_row_vat#{n+1}", '0,00'],
          ["pmt_row_discountpercentage#{n+1}", '0,00'],
          ["pmt_row_type#{n+1}", '1'],
        ]
      end

      # At this point @params is ready for hash calculation.
      digest = Digest::SHA512.new
      @params.each { |p| digest << "#{p[1]}&" if p[1].present? }
      digest << "#{PMT_KEY}&"

      # Now the remaining params are added, and the hash itself.
      @params += [
        [:pmt_sellerid, 'testikauppias'],
        [:pmt_keygeneration, '001'],
        [:pmt_rows, order.order_items_count],
        [:pmt_buyeremail, order.user_email],
        [:pmt_charset, 'UTF-8'],
        [:pmt_charsethttp, 'UTF-8'],
        [:pmt_hashversion, 'SHA-512'],
        [:pmt_hash, digest.hexdigest],
      ]
    end

    private
      def reference(number)
        sum = 0
        number.chars.map(&:to_i).reverse.each_slice(3) do |a, b, c|
          sum += 7*(a||0) + 3*(b||0) + (c||0)
        end
        '%s%s' % [number, -sum % 10]
      end
  end
end
