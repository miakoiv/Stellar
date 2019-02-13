#
# This controller takes a visitor through the onboarding process
# modelled in the Account::Onboarding module. At each step,
# the current action selects the onboarding subclass, which
# specifies the validations and other details. The forms will
# post to the validate action that terminates the process by
# calling create when there is no next step.
#
# Checking for registration is done when the onboarding module
# requires it, sending the visitor to the registration process
# if not logged in. Returning to where they left off is done by
# storing the location for the next step as set by the last time
# validate was called.
#
class OnboardingsController < ApplicationController
  before_action :load_onboarding, except: :validate
  before_action :check_for_registration, except: :validate

  # POST /onboarding/validate/:step
  def validate
    current_step = params[:step]
    @onboarding = onboarding_for_step(current_step)
    @onboarding.attributes = onboarding_params
    session[:onboarding_attributes] = @onboarding.attributes

    if @onboarding.valid?
      next_step = onboarding_next_step(current_step)
      create and return unless next_step
      session[:next_step] = url_for(action: next_step)
      redirect_to session[:next_step]
    else
      render current_step
    end
  end

  def create
    store = @onboarding.finalize!(current_user)
    session[:onboarding_attributes] = nil
    session[:next_step] = nil
    redirect_to controller: 'store', action: 'index', host: store.primary_host.fqdn
  end

  private
    def load_onboarding
      @onboarding = onboarding_for_step(action_name)
    end

    def check_for_registration
      return unless @onboarding.requires_registration?
      if user_signed_in?
        return true
      else
        store_location_for(:user, session[:next_step])
        return redirect_to new_user_registration_path
      end
    end

    def onboarding_for_step(step)
      raise ArgumentError unless step.in?(Account::Onboarding::STEPS)
      onboarding_class = "Account::Onboarding::#{step.camelize}".constantize
      onboarding_class.new(session[:onboarding_attributes])
    end

    def onboarding_next_step(step)
      Account::Onboarding::STEPS[Account::Onboarding::STEPS.index(step) + 1]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def onboarding_params
      params.require(:onboarding).permit(
        :name, :theme,
        :country_code, :locale, :subdomain,
        :admin_name, :vat_number
      )
    end
end
