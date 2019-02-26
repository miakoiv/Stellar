class CorrespondenceMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  def correspondence(store, fields)
    @store = store
    @fields = fields

    headers = {
      from: "noreply@#{ENV['STELLAR_DOMAIN']}",
      reply_to: "#{@fields[:name]} <#{@fields[:email]}>",
      to: @store.correspondents.map(&:to_s),
      subject: @fields[:subject]
    }
    headers.merge!(
      delivery_method_options: @store.smtp_delivery_method_options
    ) if @store.custom_smtp_settings?

    roadie_mail(headers)
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.primary_host.to_s})
    end
end
