#encoding: utf-8

class ProfilesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_header_and_footer
  before_action :set_categories

  # GET /profile
  def show
  end

  # GET /profile/edit
  def edit
  end

  # PATCH/PUT /profile
  def update
    respond_to do |format|
      if current_user.update(user_params)
        format.html { redirect_to profile_path, notice: t('.notice', user: current_user) }
        format.json { render :show, status: :ok, location: profile_path }
      else
        format.html { render :edit }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :email, :phone,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :locale, :password, :password_confirmation
      )
    end
end
