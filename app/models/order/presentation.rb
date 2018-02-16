class Order < ActiveRecord::Base

  def to_s
    number || "[#{id}]"
  end

  # CSS class based on order status.
  def appearance
    return nil if concluded?
    return 'text-muted' if incomplete?
    approved? && 'warning text-warning' || 'danger text-danger'
  end

  def summary
    [company_name, contact_person, shipping_city].compact.reject(&:empty?).join(', ')
  end

  # Icon name based on order status.
  def icon
    return nil if concluded?
    return 'pencil' if incomplete?
    approved? && 'cog' || 'warning'
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
