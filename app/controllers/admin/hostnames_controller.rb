#encoding: utf-8

class Admin::HostnamesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_store, only: [:create]

  authority_actions reorder: 'update'
  authorize_actions_for Hostname

  # No layout, this controller never renders HTML.

  # POST /admin/stores/1/hostnames
  def create
    @hostname = @store.hostnames.build(hostname_params)

    respond_to do |format|
      if @hostname.save
        format.js { render :create }
        format.json { render json: @hostname, status: 200 }
      else
        format.json { render json: @hostname.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/hostnames/1
  def destroy
    @hostname = Hostname.find(params[:id])

    respond_to do |format|
      if @hostname.destroy
        format.js
      end
    end
  end

  private
    def set_store
      @store = Store.find(params[:store_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hostname_params
      params.require(:hostname).permit(
        :parent_hostname_id, :fqdn
      )
    end
end
