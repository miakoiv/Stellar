class CorrespondenceMailer < ApplicationMailer

  include Roadie::Rails::Mailer

  #---
  def correspondence(store, fields)
    @store = store
    @fields = fields

    roadie_mail(
      from: "#{@fields[:name]} <#{@fields[:email]}>",
      to: @store.correspondents.map(&:to_s),
      subject: @fields[:subject]
    )
  end

  protected
    def roadie_options
      super.merge(url_options: {host: @store.primary_host.to_s})
    end
end
