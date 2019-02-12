#encoding: utf-8

class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  def send_mail(order, to, items, options)
    @store = order.store
    @order = order
    @order_items = items || order.order_items
    @bcc = options.delete(:bcc)
    @pricing = options.delete(:pricing)

    headers = {
      from: "noreply@#{ENV['STELLAR_DOMAIN']}",
      to: to,
      subject: default_i18n_subject(store: @store),
    }
    headers[:bcc] = @order.notified_users.map(&:to_s) if @bcc

    roadie_mail(headers)
  end

  alias_method :receipt, :send_mail
  alias_method :acknowledge, :send_mail
  alias_method :processing, :send_mail
  alias_method :confirmation, :send_mail
  alias_method :shipment, :send_mail
  alias_method :notification, :send_mail
  alias_method :cancellation, :send_mail
  alias_method :quotation, :send_mail

  protected
    def roadie_options
      super.merge(url_options: {host: @store.primary_host.to_s})
    end
end
