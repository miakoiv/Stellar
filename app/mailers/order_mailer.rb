#encoding: utf-8

class OrderMailer < ApplicationMailer

  def order_confirmation(order)
    @order = order
    @store = order.store
    @user = order.user

    mail(
      to: @user.to_s,
      #cc: @store.contact_person.to_s,
      subject: default_i18n_subject(store: @store)
    )
  end

end
