class Order < ActiveRecord::Base

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

  def summary
    [company_name, shipping_city].compact.reject(&:empty?).join(', ')
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

  def has_contact_info?
    contact_person.present? && contact_email.present?
  end

  def contact_string
    has_contact_info? ? "#{contact_person} <#{contact_email}>" : nil
  end

  def customer_string
    "#{customer_name} <#{customer_email}>"
  end

  def external_identifier
    [store.erp_number, number].join '/'
  end

  # Vis.js timeline representation of order events.
  def timeline_events
    events = []

    events << {
      group: id, type: 'range',
      className: (approved? ? 'primary' : 'danger'),
      content: I18n.l(completed_at.to_date),
      start: completed_at.to_date,
      end: approved_at.try(:to_date) || Time.current
    }
    events << {
      group: id, type: 'range',
      className: (concluded? ? 'success' : 'warning'),
      content: I18n.l(approved_at.to_date),
      start: approved_at.to_date,
      end: concluded_at.try(:to_date) || Time.current
    } if approved?

    events << {
      group: id, type: 'box',
      className: 'info',
      content: Order.human_attribute_name(:shipping_at),
      start: shipping_at
    } if shipping_at.present?

    events << {
      group: id, type: 'box',
      className: 'info',
      content: Order.human_attribute_name(:installation_at),
      start: installation_at
    } if installation_at.present?

    events
  end
end
