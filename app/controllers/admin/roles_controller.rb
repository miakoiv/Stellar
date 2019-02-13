class Admin::RolesController < AdminController

  before_action :set_user_and_role

  authority_actions toggle: 'update'

  # PATCH /admin/users/1/roles/el_presidente/toggle.js
  def toggle
    authorize_action_for Role, at: current_store
    if @role == :superuser
      if @user.has_cached_role?(@role)
        @user.revoke(@role)
        track @user, nil, {action: 'revoke', differences: {role: @role}}
      else
        @user.grant(@role)
        track @user, nil, {action: 'grant', differences: {role: @role}}
      end
    else
      if @user.has_cached_role?(@role, current_store)
        @user.revoke(@role, current_store)
        track @user, nil, {action: 'revoke', differences: {role: @role}}
      else
        @user.grant(@role, current_store)
        track @user, nil, {action: 'grant', differences: {role: @role}}
      end
    end

    respond_to :js
  end

  private
    def set_user_and_role
      @user = User.find(params[:user_id])
      @role = params[:id].to_sym
    end
end
