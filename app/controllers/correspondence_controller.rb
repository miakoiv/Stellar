class CorrespondenceController < ApplicationController

  protect_from_forgery with: :null_session

  def mail_form
    @store = Store.find(params[:store_id])
    @fields = correspondence_params

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

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def correspondence_params
      params.fetch(:fields, {}).permit!
    end
end
