#encoding: utf-8

module PaymentGateway
  class Checkout
    include ActiveModel::Model

    attr_accessor :params

    def initialize(order, options = {})
    end
  end
end
