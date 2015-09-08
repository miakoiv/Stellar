#encoding: utf-8

class CorrespondenceMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  def correspondence(store, fields)
    @store = store
    @fields = fields

    roadie_mail(
      from: "#{@fields[:name]} <#{@fields[:email]}>",
      to: 'rosenblad@gmail.com',
      #to: @store.contact_person.to_s,
      subject: @fields[:subject]
    )
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.host, scheme: 'http'})
    end
end
