#encoding: utf-8

class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  def order_confirmation(order)
    @order = order
    @store = order.store
    @user = order.user

    roadie_mail(
      from: "noreply@#{@store.host}",
      to: "#{@order.customer_name} <#{@order.customer_email}>",
      cc: @order.managing_users.map(&:to_s),
      subject: default_i18n_subject(store: @store)
    )
  end

  def quotation(order)
    Rails.logger.info "#{order.inspect}"
    @order = order
    @store = order.store
    @user = order.user

    roadie_mail(
      from: @order.user.to_s,
      to: "#{@order.contact_person} <#{@order.contact_email}>",
      bcc: @order.user.to_s,
      subject: default_i18n_subject(store: @store)
    )
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.host, scheme: 'http'})
    end
end
