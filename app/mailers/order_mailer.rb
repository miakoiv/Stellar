#encoding: utf-8

class OrderMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  def order_confirmation(order)
    @order = order
    @store = order.store
    @user = order.user

    roadie_mail(
      from: @store.contact_person.to_s,
      to: "#{@order.customer_name} <#{@order.customer_email}>",
      cc: @store.contact_person.to_s,
      subject: default_i18n_subject(store: @store)
    )
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.host, scheme: 'http'})
    end
end
