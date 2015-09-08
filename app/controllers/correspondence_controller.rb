#encoding: utf-8

class CorrespondenceController < ApplicationController

  skip_before_action :verify_authenticity_token

  def mail_form
    @store = Store.find(params[:store_id])
    @fields = params[:fields]

    if @fields[:nickname].present?
      raise 'Honeypot attracted a fly. Killing it with fire.'
    end
    CorrespondenceMailer.correspondence(@store, @fields).deliver_later

    redirect_to store_path, notice: t('.thank_you')
  end
end
