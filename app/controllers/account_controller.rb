#encoding: utf-8

class AccountController < ApplicationController

  def index
    render 'splash'
  end

  def onboarding
    redirect_to frontend_onboarding_path
  end
end
