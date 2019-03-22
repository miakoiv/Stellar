module Messaging

  # Messaging class for orders defines methods for sending mail
  # about the following events in the workflow: acknowledge,
  # processing, confirmation, notification, receipt, conclusion,
  # and cancellation. The store may have Message definitions for
  # each of these, which may provide customized content for the
  # mail body, or disable sending mail for this event completely.
  class Orders

    def initialize(order)
      @order = order
      @store = @order.store
      @messages = @order.order_type.messages
    end

    def send(event, options)
      options.reverse_merge!(bcc: true, pricing: true)
      options.merge!(blind_copies: @order.notified_users.map(&:to_s)) if options[:bcc]
      message = @messages.find_by(stage: event)
      disabled = @store.disable_mail? || (message && message.disabled?)
      options.merge!(content: message.content) if message
      OrderMailer.send(event, @store, @order, options) unless disabled
    end

    def acknowledge(options = {})
      send(:acknowledge, options)
    end

    def cancellation(options = {})
      send(:cancellation, options)
    end

    def conclusion(options = {})
      send(:conclusion, options)
    end

    def confirmation(options = {})
      send(:confirmation, options)
    end

    def notification(options = {})
      send(:notification, options)
    end

    def processing(options = {})
      send(:processing, options)
    end

    # Quotations are not part of the regular workflow, but mail
    # can be sent for them anyway.
    def quotation(options = {})
      send(:quotation, options)
    end

    def receipt(options = {})
      send(:receipt, options)
    end
  end
end
