#encoding: utf-8

class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  # Order confirmation for the customer. Carbon copies are sent to the users
  # responsible for managing this order, unless it's a quotation.
  def order_confirmation(order)
    @order = order
    @store = order.store
    @user = order.user

    headers = {
      from: "noreply@#{@store.host}",
      to: "#{@order.customer_name} <#{@order.customer_email}>",
      subject: default_i18n_subject(store: @store)
    }
    unless @order.is_quote?
      headers.merge!(cc: @order.managing_users.map(&:to_s))
    end
    roadie_mail(headers)
  end

  # Quotation from the user to the specified contact, blind carbon copied
  # to the sender.
  def quotation(order)
    @order = order
    @store = order.store
    @user = order.user

    headers = {
      from: @order.user.to_s,
      to: "#{@order.contact_person} <#{@order.contact_email}>",
      bcc: @order.user.to_s,
      subject: default_i18n_subject(store: @store)
    }
    roadie_mail(headers)
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.host, scheme: 'http'})
    end
end
