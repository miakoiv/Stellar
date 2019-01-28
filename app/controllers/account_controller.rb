#encoding: utf-8

class AccountController < ApplicationController

  #before_action :authenticate_user!, except: :index

  def index
    render 'splash'
  end

  def onboarding
    return render 'register' unless user_signed_in?

    @store = Store.new(locale: I18n.default_locale, country: Country.default)
    @store.tax_categories.build
  end
end
