class ApplicationMailer < ActionMailer::Base

  layout 'mailer'
  helper :application, :store

end
