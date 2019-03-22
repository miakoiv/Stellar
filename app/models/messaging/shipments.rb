module Messaging

  # Messaging class for shipments defines a method for sending mail
  # about shipments, which may have custom content through a Message
  # definition, or may be disabled completely.
  class Shipments

    def initialize(shipment)
      @shipment = shipment
      @order = @shipment.order
      @store = @order.store
      @messages = @shipment.shipping_method.messages
    end

    def shipment(options = {})
      options.reverse_merge!(bcc: true)
      options.merge!(blind_copies: @order.notified_users.map(&:to_s)) if options[:bcc]
      message = @messages.find_by(stage: :shipment)
      disabled = @store.disable_mail? || (message && message.disabled?)
      options.merge!(content: message.content) if message
      OrderMailer.shipment(@store, @order, @shipment, options) unless disabled
    end
  end
end
