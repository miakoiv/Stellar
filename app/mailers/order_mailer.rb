class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  def send_mail(store, order, options)
    @store, @order, @options = store, order, options
    @order_items = @options[:items] || @order.order_items
    roadie_mail(headers)
  end

  alias_method :acknowledge, :send_mail
  alias_method :cancellation, :send_mail
  alias_method :conclusion, :send_mail
  alias_method :confirmation, :send_mail
  alias_method :notification, :send_mail
  alias_method :processing, :send_mail
  alias_method :quotation, :send_mail
  alias_method :receipt, :send_mail

  def shipment(store, order, shipment, options)
    @store, @order, @shipment, @options = store, order, shipment, options
    @order_items = @order.order_items
    @shipment = shipment
    roadie_mail(headers)
  end

  protected

  def roadie_options
    super.merge(url_options: {host: @store.primary_host.to_s})
  end

  private

  # Constructs mail headers from instance variables
  # we have initialized earlier.
  def headers
    {
      from: "noreply@#{ENV['STELLAR_DOMAIN']}",
      to: @options[:to],
      subject: default_i18n_subject(store: @store, order: @order)
    }.tap do |h|
      h[:bcc] = @options[:blind_copies] if @options[:bcc]
      h.merge!(
        from: @store.smtp_user_name,
        delivery_method_options: @store.smtp_delivery_method_options
      ) if @store.custom_smtp_settings?
    end
  end
end
