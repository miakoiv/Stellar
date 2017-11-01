#encoding: utf-8

class Admin::RolesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user_and_role

  authority_actions toggle: 'update'

  # No layout, this controller never renders HTML.

  # PATCH /admin/users/1/roles/el_presidente/toggle.js
  def toggle
    authorize_action_for Role, at: current_store
    if @role == :superuser
      @user.has_cached_role?(@role) ? @user.revoke(@role) : @user.grant(@role)
    else
      @user.has_cached_role?(@role, current_store) ? @user.revoke(@role, current_store) : @user.grant(@role, current_store)
    end

    respond_to :js
  end

  private
    def set_user_and_role
      @user = User.find(params[:user_id])
      @role = params[:id].to_sym
    end
end
