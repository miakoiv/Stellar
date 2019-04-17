class Order < ApplicationRecord

  def to_s
    return "#{Order.human_attribute_name(:number)} #{number}" if complete?
    Order.human_attribute_value(:status, :incomplete)
  end

  # CSS class based on order status.
  def appearance
    return 'text-muted' if incomplete? || cancelled?
    return nil if concluded?
    return 'text-danger' if current?
    fully_shipped? ? 'text-warning' : 'warning text-warning'
  end

  def life_pro_tip
    return [:info, '.cancelled'] if cancelled?
    return [:info, '.concluded'] if concluded?
    return [:info, '.incomplete'] if incomplete?
    return [:danger, '.current'] if current?
    return [:warning, '.shipped'] if concludable?
    [:warning, '.pending']
  end

  def billing_customer
    billing_address&.to_identifier
  end

  def shipping_customer
    shipping_address&.to_identifier
  end

  # Icon name based on order status.
  def icon
    return 'ban' if cancelled?
    return 'pencil' if incomplete?
    return nil if concluded?
    return 'question-circle' if current?
    fully_shipped? && 'exclamation-circle' || 'truck'
  end

  def as_json(options = {})
    super(methods: :checkout_phase)
  end

  # Email recipient for billing related messages.
  def billing_recipient
    "#{billing_address.name} <#{customer_email}>"
  end

  def has_contact_email?
    contact_email.present?
  end

  # Email recipient for shipping related messages.
  # Check #has_contact_email? first.
  def shipping_recipient
    "#{shipping_address.name} <#{contact_email}>"
  end

  def external_identifier
    [store.erp_number, number].join '/'
  end
end
