#encoding: utf-8

class ErrorsController < ApplicationController

  layout 'error'

  def show
    @status_code = (request.path.match(/\d{3}/) || ['500'])[0].to_i
  end
end
