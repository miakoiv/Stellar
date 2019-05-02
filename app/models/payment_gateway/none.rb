#
# Payment gateway that doesn't collect payments but provides
# an interface to confirm the order and create a payment object.
#
module PaymentGateway
  class None

    include ActiveModel::Model

    attr_accessor :order

    def initialize(attributes = {})
      super
      raise ArgumentError if order.nil?
    end

    # This payment gateway doesn't collect actual payments.
    def collect_payment?
      false
    end

    def to_partial_path
      'payment_gateway/none'
    end
  end
end
