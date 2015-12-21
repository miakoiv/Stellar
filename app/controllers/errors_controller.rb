#encoding: utf-8

class ErrorsController < ActionController::Base

  layout 'error'

  # The application layout needs this.
  def current_store
    @current_store ||= Store.find_by(host: request.host)
  end
  helper_method :current_store

  def show
    @status_code = (request.path.match(/\d{3}/) || ['500'])[0].to_i
  end
end
