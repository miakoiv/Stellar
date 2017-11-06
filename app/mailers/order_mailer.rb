#encoding: utf-8

class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  def send_mail(order, to, items, pricing)
    @store = order.store
    @order = order
    @order_items = items || order.order_items
    @pricing = pricing

    roadie_mail({
      from: "noreply@#{@store.primary_host.fqdn}",
      to: to,
      subject: default_i18n_subject(store: @store),
      bcc: @order.notified_users.map(&:to_s)
    })
  end

  alias_method :receipt, :send_mail
  alias_method :acknowledge, :send_mail
  alias_method :processing, :send_mail
  alias_method :confirmation, :send_mail
  alias_method :shipment, :send_mail
  alias_method :notification, :send_mail
  alias_method :cancellation, :send_mail

  protected
    def roadie_options
      super.merge(url_options: {host: @store.primary_host.fqdn})
    end
end
