class CorrespondenceController < ApplicationController

  skip_before_action :verify_authenticity_token

  def mail_form
    @store = Store.find(params[:store_id])
    @fields = params[:fields]

    if @fields[:nickname].present?
      raise 'Honeypot attracted a fly. Killing it with fire.'
    end

    if @store.disable_mail?
      logger.info "Sending of e-mail is currently disabled, aborting"
    else
      CorrespondenceMailer.correspondence(@store, @fields).deliver_later
    end

    redirect_to root_path, notice: t('.thank_you')
  end
end
