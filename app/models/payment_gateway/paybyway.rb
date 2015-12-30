#encoding: utf-8

module PaymentGateway
  class Paybyway
    include ActiveModel::Model

    attr_accessor :params

    def initialize(order, options = {})
    end

    def to_partial_path
      'payment_gateway/paybyway'
    end
  end
end
